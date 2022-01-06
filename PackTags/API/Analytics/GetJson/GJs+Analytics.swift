//
//  GJs+Analytics.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

//Functions for analytics
extension GetJson {
    
    class func load_Profile (igBId: String, token:String?, completion block: @escaping ((Profile) -> ())) {
        
        // Request 3. Get the business IG data
        
        guard let token = token else { return }
        
        // Request 4. Send many requests to filter the posts
        findMediaLimit(IgBusinessAccount: igBId, token: token) { (value) in
        
            guard let encodedUrl = self.buildURLAPIGraph(IgBusinessAccount: igBId, token: token, i: value) else { return }
            
            GetJson.isOkToSaveJsonDataInDir = true //local save
            
            GenericJSONParser.cURL2(of: Profile.self, from: encodedUrl, Completion: {(Json) in
                block(Json as! Profile)
            })
        }
    }
    
    class func findMediaLimit(IgBusinessAccount: String, token: String, Completion block: @escaping ((Int) -> ())) {
        
        let igBId = IgBusinessAccount
        var mCount: [Int] = []
    
        let group = DispatchGroup()
        
        for i in 1...12 {
            
            //Test 12 urls to find the limit
            guard let encodedUrl = self.buildURLAPIGraph(IgBusinessAccount: igBId, token: token, i: i) else {return }
          
            group.enter()
            
            GenericJSONParser.cURL2(of: Profile.self, from: encodedUrl, Completion: {(Json) in
                
                let js = (Json as! Profile)
                if js.username != nil { //means no error returned
                    
                    /*Hack: Api sometimes fail to return an error and returns a json,
                    But the Json media's count is actually the limit to find*/
                    mCount.append(js.media?.data.count ?? 0)
                }
                
                group.leave()
                
            })

        }
        
        group.notify(queue: .main) {
            
            let limit = mCount.max() ?? 0
            
            //print("Media limit: \(mCount.count)") old
            print("Media limit: \(limit)")
            
            block(limit)
        }
    }
    
    class func buildURLAPIGraph (IgBusinessAccount: Any, token:String, i: Int) -> String? {
        let IgBId = IgBusinessAccount
        
        let limit = "\(i)"
        let url = "https://graph.facebook.com/\(apiGph_version)/\(IgBId)?fields=biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,recently_searched_hashtags,insights.metric(reach,impressions,profile_views,follower_count).period(day),media.limit(\(limit)){media_type,caption,timestamp,media_url,comments_count,comments,is_comment_enabled,username,like_count,media_product_type,insights.metric(reach,impressions,engagement)}&access_token=\(token)&checkType=FULL"
        
        return encode_url (url: url)
    }
}
