//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

protocol InstagramGraphServicing {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    )
    func loadProfileForAnalytics(completion: @escaping (Profile) -> Void)
}

private enum InstagramGraphServiceError: LocalizedError {
    case invalidURL(String)
    case missingCredentials(hasToken: Bool, hasInstagramBusinessId: Bool)
    case emptyResponse
    case unexpectedResponse
    case graphHTTPError(statusCode: Int, body: String)
    case decodingFailed(type: String, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid Instagram Graph URL: \(url)"
        case let .missingCredentials(hasToken, hasInstagramBusinessId):
            return "Missing Instagram Graph credentials. hasToken=\(hasToken), hasInstagramBusinessId=\(hasInstagramBusinessId)"
        case .emptyResponse:
            return "Instagram Graph returned an empty response."
        case .unexpectedResponse:
            return "Instagram Graph returned an unexpected response."
        case let .graphHTTPError(statusCode, body):
            return "Instagram Graph HTTP error \(statusCode): \(body)"
        case let .decodingFailed(type, body):
            return "Could not decode Instagram Graph response as \(type): \(body)"
        }
    }
}

final class InstagramGraphService: InstagramGraphServicing {
    typealias ResultHandler<T> = (Result<T, Error>) -> Void
    
    private let apiGraphVersion: String
    private let settings: any ConnectedInsightsSettingsProtocol

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        apiGraphVersion: String = ConnectedInsightsConfiguration.production.graphAPIVersion
    ) {
        self.settings = settings
        self.apiGraphVersion = apiGraphVersion
    }

    private var fbToken: String {
        settings.facebookToken ?? ""
    }

    private var igBId: String {
        settings.instagramBusinessAccountId ?? ""
    }

    func fetchDataFromUrl<T: Decodable>(
        of type: T.Type,
        from url: String,
        completion: @escaping ResultHandler<Any>
    ) {
        fetchGraphData(from: url) { result in
            switch result {
            case .failure(let error):
                self.logGraphFailure(error, url: url)
                completion(.failure(error))
            case .success(let data):
                self.handleSuccessResult(of: T.self, data: data, sourceURL: url, completion: completion)
            }
        }
    }

    private func handleSuccessResult<T: Decodable>(
        of type: T.Type,
        data: Data,
        sourceURL: String,
        completion: @escaping ResultHandler<Any>
    ) {
        if T.self == Profile.self {
            guard let decodedProfile = GenericJSONParser.ParseJs(of: T.self, data: data) as? Profile else {
                completion(.failure(decodingError(for: T.self, data: data, sourceURL: sourceURL)))
                return
            }
            completion(.success(decodedProfile))
        } else if T.self == Media.self {
            guard let decodedMedia = GenericJSONParser.ParseJs(of: T.self, data: data) as? Media else {
                completion(.failure(decodingError(for: T.self, data: data, sourceURL: sourceURL)))
                return
            }
            let mediaData = decodedMedia.data.compactMap { $0 }
            completion(.success(mediaData))
        } else {
            guard let decodedObject = GenericJSONParser.ParseJs2(of: T.self, data: data) else {
                completion(.failure(decodingError(for: T.self, data: data, sourceURL: sourceURL)))
                return
            }
            completion(.success(decodedObject))
        }
    }

    private func fetchGraphData(
        from urlString: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let hasToken = !fbToken.isEmpty
        let hasInstagramBusinessId = !igBId.isEmpty

        guard hasToken, hasInstagramBusinessId else {
            completion(.failure(InstagramGraphServiceError.missingCredentials(
                hasToken: hasToken,
                hasInstagramBusinessId: hasInstagramBusinessId
            )))
            return
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(InstagramGraphServiceError.invalidURL(redacted(urlString))))
            return
        }

        print("[ConnectedInsights][Graph] Request \(apiGraphVersion): \(redacted(urlString))")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(InstagramGraphServiceError.unexpectedResponse))
                return
            }

            guard let data = data else {
                completion(.failure(InstagramGraphServiceError.emptyResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(InstagramGraphServiceError.graphHTTPError(
                    statusCode: httpResponse.statusCode,
                    body: self.responsePreview(data)
                )))
                return
            }

            completion(.success(data))
        }.resume()
    }

    private func decodingError<T: Decodable>(
        for type: T.Type,
        data: Data,
        sourceURL: String
    ) -> Error {
        let error = InstagramGraphServiceError.decodingFailed(
            type: String(describing: type),
            body: responsePreview(data)
        )
        logGraphFailure(error, url: sourceURL)
        return error
    }

    private func logGraphFailure(_ error: Error, url: String) {
        print("[ConnectedInsights][Graph] Failure: \(error.localizedDescription)")
        print("[ConnectedInsights][Graph] URL: \(redacted(url))")
    }

    private func responsePreview(_ data: Data) -> String {
        let body = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"
        return redacted(String(body.prefix(1_500)))
    }

    private func redacted(_ value: String) -> String {
        value.replacingOccurrences(
            of: #"access_token=[^&\s]+"#,
            with: "access_token=<redacted>",
            options: .regularExpression
        )
    }
}

//MARK: - SmartG
extension InstagramGraphService {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        findHashtagUrl(searchedHashtag: searchedHashtag) { result in
            switch result {
            case .success(let mediaSearchURL):
                self.getMedia(for: mediaSearchURL, completion: completion)
            case .failure(let error):
                print("Error finding hashtag URL: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func getMedia(
        for url: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        fetchDataFromUrl(of: Media.self, from: url) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            case .success(let data):
                if let dataMedia = data as? [DataMedia] {
                    completion(.success(dataMedia))
                } else {
                    print("Error: getMedia has no dataMedia")
                }
            }
        }
    }

    private func findHashtagUrl(searchedHashtag: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let searchURL = constructHashtagSearchURL(searchedHashtag: searchedHashtag) else {
            completion(.failure(InstagramGraphServiceError.invalidURL(searchedHashtag)))
            return
        }

        fetchGraphData(from: searchURL) { result in
            switch result {
            case .success(let data):
                self.handleHashtagIdResponse(data: data) { result in
                    switch result {
                    case .success(let mediaSearchURL):
                        completion(.success(mediaSearchURL))
                    case .failure(let error):
                        print("Error decoding JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                self.logGraphFailure(error, url: searchURL)
                completion(.failure(error))
            }
        }
    }

    private func handleHashtagIdResponse(data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let response = try JSONDecoder().decode(HashtagIdResponse.self, from: data)
            guard let id = response.data.first?.id else {
                completion(.failure(InstagramGraphServiceError.decodingFailed(
                    type: String(describing: HashtagIdResponse.self),
                    body: responsePreview(data)
                )))
                return
            }
            guard let mediaSearchURL = constructHashtagMediaSearchURL(hashtagID: id) else {
                completion(.failure(InstagramGraphServiceError.invalidURL(id)))
                return
            }
            completion(.success(mediaSearchURL))
        } catch {
            completion(.failure(error))
        }
    }
}

extension InstagramGraphService {
    private func constructHashtagSearchURL(searchedHashtag: String) -> String? {
        let url = "https://graph.facebook.com/\(apiGraphVersion)/ig_hashtag_search?user_id=\(igBId)&q=\(searchedHashtag)&access_token=\(fbToken)"
        return url.encodeUrl()
    }

    private func constructHashtagMediaSearchURL(hashtagID: String) -> String? {
        let limit = "25"
        let m_type = "top_media"
        let base = "https://graph.facebook.com"
        let fieldsArray = [
            "caption",
            "comments_count",
            "like_count",
            "media_type",
            "media_url",
            "timestamp",
            "id",
            "media_product_type"
        ]

        let fields = "fields=" + fieldsArray.joined(separator: ",")
        let options = "\(m_type)?\(fields)&user_id=\(igBId)&limit=\(limit)"
        let htgUrl = "\(base)/\(apiGraphVersion)/\(hashtagID)/\(options)&access_token=\(fbToken)"
        return htgUrl.encodeUrl()
    }
}

//MARK: -Analytics
//Functions for analytics
extension InstagramGraphService {
    func loadProfileForAnalytics(completion: @escaping (Profile) -> Void) {
        findMediaLimit { value in
            guard let encodedUrl = self.buildAPIGraphUrlString(foundLimit: value) else { return }
            
            DocumentDirectory.isOkToSaveJsonDataInDir = true //local save
            
            self.fetchDataFromUrl(of: Profile.self, from: encodedUrl) { result in
                if case let .success(profileJson) = result, let profile = profileJson as? Profile {
                    completion(profile)
                }
            }
        }
    }
}

extension InstagramGraphService {
    private func findMediaLimit(completion: @escaping ((Int) -> Void)) {
        var mCount: [Int] = []
        let group = DispatchGroup()
        
        for i in 1...12 {
            guard let encodedUrl = self.buildAPIGraphUrlString(foundLimit: i) else { return }
          
            group.enter()
            
            fetchDataFromUrl(of: Profile.self, from: encodedUrl) { result in
                if case let .success(profileJson) = result, let profile = profileJson as? Profile {
                    if profile.username != nil {
                        //means no error returned
                        /*Hack: Api sometimes fail to return an error and returns a json,
                        But the Json media's count is actually the limit to find*/
                        mCount.append(profile.media?.data.count ?? 0)
                    }
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let limit = mCount.max() ?? 0
            print("Media limit: \(limit)")
            completion(limit)
        }
    }
    
    private func buildAPIGraphUrlString(foundLimit: Int) -> String? {
        let limit = "\(foundLimit)"

        let insightsMetricsFields = [
            "reach",
            "impressions",
            "profile_views",
            "follower_count"
        ]

        let mediaMetricsFields = [
            "media_type",
            "caption",
            "timestamp",
            "media_url",
            "comments_count",
            "comments",
            "is_comment_enabled",
            "username",
            "like_count",
            "media_product_type",
            "insights.metric(reach,impressions,total_interactions)"
        ]

        let fields = [
            "biography",
            "name",
            "followers_count",
            "follows_count",
            "id",
            "ig_id",
            "media_count",
            "profile_picture_url",
            "username",
            "website",
            "recently_searched_hashtags",
            "insights.metric(\(insightsMetricsFields.joined(separator: ","))).period(day)",
            "media.limit(\(limit)){\(mediaMetricsFields.joined(separator: ","))}"
        ]
        
        let startPath = "https://graph.facebook.com/" + apiGraphVersion + "/" + igBId
        let fieldsPath = "?fields=" + fields.joined(separator: ",")
        let endPath = "&access_token=\(fbToken)&checkType=FULL"

        let url = startPath + fieldsPath + endPath

        return url.encodeUrl()
    }
}

// MARK: - Discovery
extension InstagramGraphService {
    // FIX URL
    func business_discovery_url (account:String) -> String? {
        let limit = 12
        let url = "https://graph.facebook.com/\(apiGraphVersion)/\(igBId)?fields=business_discovery.username(\(account)){biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,media.limit(\(limit){media_type,caption,timestamp,media_url,comments_count,username,like_count,media_product_type}}&access_token=\(fbToken)"
        return url.encodeUrl()
    }
}
