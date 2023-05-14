import Foundation

extension GetJson {
    class func igHashtagSearch(searchedHashtag: String, completion block: @escaping((Any) -> ())) {
        let getJson = GetJson()
        getJson.findHashtagUrl(searchedHashtag: searchedHashtag) { (url) in
            GetJson.cURL2(of: Media.self, from: url) { (result) in
                block(result)
            }
        }
    }
}

extension GetJson {
    private func constructHashtagSearchURL(searchedHashtag: String) -> String? {
        let url = "https://graph.facebook.com/\(apiGph_version)/ig_hashtag_search?user_id=\(igBId)&q=\(searchedHashtag)&access_token=\(fbToken)"
        return url.encodeUrl()
    }

    private func extractHashtagID(fromJSONString JSONString: String) -> String? {
        return JSONString.filter { "0"..."9" ~= $0 }
    }

    private func constructHashtagMediaSearchURL(hashtagID: String) -> String? {
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

    private func extractMediaSearchURL(
        fromJSONString jsonString: String
    ) -> String? {
        guard let hashtagID = extractHashtagID(fromJSONString: jsonString) else {
            print("Unable to extract hashtag ID from API response.")
            return nil
        }
        guard let mediaSearchURL = constructHashtagMediaSearchURL(hashtagID: hashtagID) else {
            print("Unable to construct media search URL from hashtag ID.")
            return nil
        }
        return mediaSearchURL
    }

    private func findHashtagUrl(
        searchedHashtag: String,
        completion block: @escaping((String) -> ())
    ) {
        guard let searchURL = constructHashtagSearchURL(searchedHashtag: searchedHashtag) else { return }
        
        GenericJSONParser.download(fromURLString: searchURL) { [weak self] (result) in
            switch result {
            case .success(let data):
                guard
                    let jsonString = String(data: data, encoding: .utf8),
                    let mediaSearchURL = self?.extractMediaSearchURL(
                        fromJSONString: jsonString)
                else {
                    print("download json")
                    return
                }
                block(mediaSearchURL)
            case .failure(let error):
                print("download json:", error)
            }
        }
    }
}
