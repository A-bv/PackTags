//
//  GJs+Analytics.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

//Functions for analytics
extension ApiService {
    static func loadProfileForAnalytics(completion: @escaping (Profile) -> Void) {
        findMediaLimit { value in
            guard let encodedUrl = self.buildURLAPIGraph(foundLimit: value) else { return }
            
            DocumentDirectory.isOkToSaveJsonDataInDir = true //local save
            
            ApiService.fetchDataFromIgApi(of: Profile.self, from: encodedUrl) { result in
                if case let .success(profileJson) = result, let profile = profileJson as? Profile {
                    completion(profile)
                }
            }
        }
    }
}

extension ApiService {
    // TODO: Test if this function is still needed
    class private func findMediaLimit(completion: @escaping ((Int) -> Void)) {
        var mCount: [Int] = []
        let group = DispatchGroup()
        
        for i in 1...12 {
            guard let encodedUrl = self.buildURLAPIGraph(foundLimit: i) else { return }
          
            group.enter()
            
            ApiService.fetchDataFromIgApi(of: Profile.self, from: encodedUrl) { result in
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
    
    class private func buildURLAPIGraph(foundLimit: Int) -> String? {
        let limit = "\(foundLimit)"
        let url = "https://graph.facebook.com/\(apiGph_version)/\(igBId)?fields=biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,recently_searched_hashtags,insights.metric(reach,impressions,profile_views,follower_count).period(day),media.limit(\(limit)){media_type,caption,timestamp,media_url,comments_count,comments,is_comment_enabled,username,like_count,media_product_type,insights.metric(reach,impressions,engagement)}&access_token=\(fbToken)&checkType=FULL"
        
        return url.encodeUrl()
    }
}
