import Foundation

extension GetJson {
    class func igHashtagSearch(searchedHashtag: String, completion block: @escaping((Any) -> ())) {
        GetJson.findHashtagUrl(searchedHashtag: searchedHashtag) { (url) in
            GetJson.cURL2(of: Media.self, from: url) { (result) in
                block(result)
            }
        }
    }
}

extension GetJson {
    private class func findHashtagUrl(
        searchedHashtag: String,
        completion block: @escaping((String) -> ())
    ) {
        guard let searchURL = constructHashtagSearchURL(searchedHashtag: searchedHashtag) else { return }
        
        GenericJSONParser.download(fromURLString: searchURL) { (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    handleHashtagIdResponse(data: data) { result in
                        switch result {
                        case .success(let mediaSearchURL):
                            block(mediaSearchURL)
                        case .failure(let error):
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("download json:", error)
            }
        }
    }
    
    private class func constructHashtagSearchURL(searchedHashtag: String) -> String? {
        let url = "https://graph.facebook.com/\(apiGph_version)/ig_hashtag_search?user_id=\(igBId)&q=\(searchedHashtag)&access_token=\(fbToken)"
        return url.encodeUrl()
    }

    private class func constructHashtagMediaSearchURL(hashtagID: String) -> String? {
        let limit = "25" //max value
        let m_type = "top_media" //"recent_media"

        let base = "https://graph.facebook.com"

        let fieldsArray = [
            "caption", "comments_count", "like_count", "media_type", "media_url", "timestamp", "id", "media_product_type"]
        let fields = "fields=" + fieldsArray.joined(separator: ",")
        let options = "\(m_type)?\(fields)&user_id=\(igBId)&limit=\(limit)"

        let htgUrl = "\(base)/\(apiGph_version)/\(hashtagID)/\(options)&access_token=\(fbToken)"
        return htgUrl.encodeUrl()
    }

    private class func handleHashtagIdResponse(data: Data, completion: @escaping (Result<String, Error>) -> Void) {
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
