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
            guard let encodedUrl = self.buildAPIGraphUrlString(foundLimit: value) else { return }
            
            DocumentDirectory.isOkToSaveJsonDataInDir = true //local save
            
            ApiService.fetchDataFromUrl(of: Profile.self, from: encodedUrl) { result in
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
            guard let encodedUrl = self.buildAPIGraphUrlString(foundLimit: i) else { return }
          
            group.enter()
            
            ApiService.fetchDataFromUrl(of: Profile.self, from: encodedUrl) { result in
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
    
    class private func buildAPIGraphUrlString(foundLimit: Int) -> String? {
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
            "media_product_type"
        ]
        /*
            "insights.metric(reach,impressions,engagement)"
        ]*/

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
