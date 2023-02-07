//
//  GJss.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
//Functions for SmartG

import Foundation

extension GetJson {
    class func findHashtagUrl (searchedHashtag:String, completion block: @escaping((String) -> ())) {
        let url = "https://graph.facebook.com/\(apiGph_version)/ig_hashtag_search?user_id=\(igBId)&q=\(searchedHashtag)&access_token=\(fbToken)"
        guard let e_url = url.encodeUrl() else { return }

        GenericJSONParser.download(fromURLString: e_url) { (result) in
            switch result {
            case .success(let data):
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                    let hashtag_id = JSONString.filter { "0"..."9" ~= $0 }
                    let limit = "25" //max value
                    let m_type = "top_media" //recent_media
                    
                    let htg_url = "https://graph.facebook.com/\(apiGph_version)/\(hashtag_id)/\(m_type)?fields=caption,comments_count,like_count,media_type,media_url,timestamp,id,media_product_type&user_id=\(igBId)&limit=\(limit)&access_token=\(fbToken)"
                    
                    guard let e_htg_url = htg_url.encodeUrl()
                    else {
                        return
                    }
                    block(e_htg_url)
                 }
            case .failure(let error):
                print("download json:", error)
            }
        }
    }
    
    class func igHashtagSearch (
        searchedHashtag: String,
        completion block: @escaping((Any) -> ())
    ) {
        findHashtagUrl(
            searchedHashtag: searchedHashtag,
            completion: { (url) in
            GetJson.cURL2(of: Media.self, from: url, Completion: { (result) in
                block(result)
            })
        })
    }
}
