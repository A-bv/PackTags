//
//  GJss.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

//Functions for SmartG
extension GetJson {
    
    class func ig_hashtag_search (IgBId: Any, token:String, s_Hashtag:String, Completion block: @escaping((Media) -> ())) {
        //Hashtags search
        let url = "https://graph.facebook.com/\(apiGph_version)/ig_hashtag_search?user_id=\(IgBId)&q=\(s_Hashtag)&access_token=\(token)"
        guard let e_url = encode_url (url: url) else {return}
        
        GenericJSONParser.download(fromURLString: e_url) { (result) in
            switch result {
            case .success(let data):
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                    let hashtag_id = JSONString.filter { "0"..."9" ~= $0 }
                    
                    //full
                    let limit = "25" //max value
                    let m_type = "top_media" //recent_media
                    let htg_url = "https://graph.facebook.com/\(apiGph_version)/\(hashtag_id)/\(m_type)?fields=caption,comments_count,like_count,media_type,media_url,timestamp,id,media_product_type&user_id=\(IgBId)&limit=\(limit)&access_token=\(token)"
                    
                    
                    guard let e_htg_url = encode_url (url: htg_url) else {return}
                    
                    GenericJSONParser.cURL2(of: Media.self, from: e_htg_url, Completion: { (result) in
                        block(result as! Media)
                    })
                    
                }
                
            case .failure(let error):
                print("loadJson error:", error)
            }
        }
        
         
        
    }
    
    
    class func ig_hashtag_search2 (IgBId: Any, token:String, s_Hashtag:String, Completion block: @escaping((Any) -> ())) { //PLLLL
            let url =  "https://iosacademy.io/api/v1/courses/index.php"
    
            GenericJSONParser.download(fromURLString: url) { (result) in
    
                switch result {
                    case .success(let data):
                    if let JSONString = String(data: data, encoding: String.Encoding.utf8) {

                        guard let e_htg_url = encode_url (url: url) else {return}
                
                        GenericJSONParser.cURL2(of: Course.self, from: e_htg_url, Completion: { (result) in
                            block(result)
                        })
                    }
            
                case .failure(let error):
                    print("loadJson error:", error)
                }
            }
    }
    
    class func business_discovery_url (IgBId: Any, token:String,account:String) -> String? {
        //Business discovery
        //
        let limit = 12
        let url = "https://graph.facebook.com/\(apiGph_version)/\(IgBId)?fields=business_discovery.username(\(account)){biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,media.limit(\(limit){media_type,caption,timestamp,media_url,comments_count,username,like_count,media_product_type}}&access_token=\(token)"
        
        return encode_url (url: url)
    }
    
}
