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
    class func findHashtagUrl (s_Hashtag:String, Completion block: @escaping((String) -> ())) {
        let url = "https://graph.facebook.com/\(apiGph_version)/ig_hashtag_search?user_id=\(igBId)&q=\(s_Hashtag)&access_token=\(fbToken)"
        guard let e_url = encode_url (url: url) else {
            return
        }
        GenericJSONParser.download(fromURLString: e_url) { (result) in
            switch result {
            case .success(let data):
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                    let hashtag_id = JSONString.filter { "0"..."9" ~= $0 }
                    let limit = "25" //max value
                    let m_type = "top_media" //recent_media
                    
                    let htg_url = "https://graph.facebook.com/\(apiGph_version)/\(hashtag_id)/\(m_type)?fields=caption,comments_count,like_count,media_type,media_url,timestamp,id,media_product_type&user_id=\(igBId)&limit=\(limit)&access_token=\(fbToken)"
                    
                    guard let e_htg_url = encode_url (url:htg_url)
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
    
    class func ig_hashtag_search (s_Hashtag: String, Completion block: @escaping((Any) -> ())) {
        findHashtagUrl(s_Hashtag: s_Hashtag, Completion: { (url) in
            GetJson.cURL2(of: Media.self, from: url, Completion: { (result) in
                block(result)
            })
        })
    }
}

extension GetJson {
    class func business_discovery_url (account:String) -> String? {
        //Business discovery
        //
        let limit = 12
        let url = "https://graph.facebook.com/\(apiGph_version)/\(igBId)?fields=business_discovery.username(\(account)){biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,media.limit(\(limit){media_type,caption,timestamp,media_url,comments_count,username,like_count,media_product_type}}&access_token=\(fbToken)"
        return encode_url (url: url)
    }
}
