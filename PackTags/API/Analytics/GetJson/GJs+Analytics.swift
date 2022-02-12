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
    
    class func load_Profile (completion block: @escaping ((Profile) -> ())) {
        
        findMediaLimit() { (value) in
        
            guard let encodedUrl = self.buildURLAPIGraph(i: value) else { return }
            
            GetJson.isOkToSaveJsonDataInDir = true //local save
            
            GetJson.cURL2(of: Profile.self, from: encodedUrl, Completion: {(Json) in
                block(Json as! Profile)
            })
        }
    }
    
    class func findMediaLimit(Completion block: @escaping ((Int) -> ())) {
        
        var mCount: [Int] = []
        let group = DispatchGroup()
        for i in 1...12 {

            //Test 12 urls to find the limit
            guard let encodedUrl = self.buildURLAPIGraph(i: i) else {return }
          
            group.enter()
            
            GetJson.cURL2(of: Profile.self, from: encodedUrl, Completion: {(Json) in
                
                guard let js = (Json as? Profile) else {return}
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
    
    class func buildURLAPIGraph (i: Int) -> String? {
        
        let limit = "\(i)"
        let url = "https://graph.facebook.com/\(apiGph_version)/\(igBId)?fields=biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,recently_searched_hashtags,insights.metric(reach,impressions,profile_views,follower_count).period(day),media.limit(\(limit)){media_type,caption,timestamp,media_url,comments_count,comments,is_comment_enabled,username,like_count,media_product_type,insights.metric(reach,impressions,engagement)}&access_token=\(fbToken)&checkType=FULL"
        
        return encode_url (url: url)
    }
}
