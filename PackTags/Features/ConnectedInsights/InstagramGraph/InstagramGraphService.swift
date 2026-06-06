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

final class InstagramGraphService: InstagramGraphServicing {
    typealias ResultHandler<T> = (Result<T, Error>) -> Void
    
    private let apiGraphVersion = "v19.0"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private var fbToken: String {
        defaults.string(forKey: "fbToken") ?? ""
    }

    private var igBId: String {
        defaults.string(forKey: "IgBId") ?? ""
    }

    func fetchDataFromUrl<T: Decodable>(
        of type: T.Type,
        from url: String,
        completion: @escaping ResultHandler<Any>
    ) {
        GenericJSONParser.download(fromURLString: url) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                self.handleSuccessResult(of: T.self, data: data, completion: completion)
            }
        }
    }

    private func handleSuccessResult<T: Decodable>(
        of type: T.Type,
        data: Data,
        completion: @escaping ResultHandler<Any>
    ) {
        if T.self == Profile.self {
            guard let decodedProfile = GenericJSONParser.ParseJs(of: T.self, data: data) as? Profile else {
                return
            }
            completion(.success(decodedProfile))
        } else if T.self == Media.self {
            guard let decodedMedia = GenericJSONParser.ParseJs(of: T.self, data: data) as? Media else {
                return
            }
            let mediaData = decodedMedia.data.compactMap { $0 }
            completion(.success(mediaData))
        } else {
            guard let decodedObject = GenericJSONParser.ParseJs2(of: T.self, data: data) else {
                return
            }
            completion(.success(decodedObject))
        }
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
        guard let searchURL = constructHashtagSearchURL(searchedHashtag: searchedHashtag) else { return }

        GenericJSONParser.download(fromURLString: searchURL) { result in
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
                print("download json:", error)
                completion(.failure(error))
            }
        }
    }

    private func handleHashtagIdResponse(data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let response = try JSONDecoder().decode(HashtagIdResponse.self, from: data)
            guard let id = response.data.first?.id else { return }
            guard let mediaSearchURL = constructHashtagMediaSearchURL(hashtagID: id) else {
                print("Could not construct Hashtag Media Search URL")
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
