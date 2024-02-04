//
//  processJsonAPIGraph.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

var mode: Int = 0
var rawInsights = true

//MARK: - Process
// Additional operations on the obtained Json data

enum DataTransformer {}

extension DataTransformer {
    enum ProfileDataTransformer {}
}

extension DataTransformer.ProfileDataTransformer {
    static func transform(response: Profile) -> TransformedProfileModel? {
        let top = response
        
        guard let metrics = computeMetrics(profileResponse: response) else { return nil }
        
        // 0: likes 1:comments
        let sum0 = (metrics.likeArray as NSArray).value(forKeyPath: "@sum.floatValue")
        let sum1 = (metrics.commentArray as NSArray).value(forKeyPath: "@sum.floatValue")
        
        let avg0 = StringFormatter.averageElementsOfArray(array: metrics.likeArray)
        let avg1 = StringFormatter.averageElementsOfArray(array: metrics.commentArray)

        let captions = metrics.captions
        let times = metrics.times

        //Basic
        let usr = top.username
        let isPv = false

        let engagementRates = [
            metrics.engagementRateFollowers,
            metrics.engagementRateReach,
            metrics.engagementRateImpressions]
        
        var avg2 = [CGFloat?]()
        var maxR = [CGFloat?]()
        
        for er in engagementRates {
            avg2.append(StringFormatter.averageElementOfArrayCGFloat(array: er))
            maxR.append(er.reduce(CGFloat.leastNormalMagnitude, { max($0, CGFloat($1)) }))
        }
        
        let data = TransformedProfileModel(
            usr: usr,
            isPv: isPv,
            sum0: (sum0 as! Int),
            sum1: (sum1 as! Int),
            avg0: avg0,
            avg1: avg1,
            rates: engagementRates[mode],
            pTimes: times,
            avg2: avg2[mode],
            maxR: maxR[mode],
            captions: captions)
        
        return data
    }

    static private func computeMetrics(profileResponse:Profile) -> SubTransformedProfileModel? {
        var likeArray = [Int]()
        var commentArray = [Int]()
        var sumLikesCommentsArray = [CGFloat]()
        var impressions = [CGFloat]()
        var reachArray = [CGFloat]()
        var times = [Double?]()
        var captions = [String?]()
    
        guard let numberOfMedias = profileResponse.media?.data.count else {
            print("No media")
            return nil
        }
        
        for i in 0..<numberOfMedias {
            let mediaData = profileResponse.media?.data[i]
            
            likeArray.append(mediaData?.like_count ?? 0)
            commentArray.append(mediaData?.comments_count ?? 0)
            captions.append(mediaData?.caption ?? "")
 
            if let insightsData = mediaData?.insights?.data, insightsData.count > 2 {
                let mediaSumLikesComment = CGFloat(mediaData?.insights?.data[2]?.values[0]?.value ?? 0)
                let mediaImpressions = CGFloat(mediaData?.insights?.data[1]?.values[0]?.value ?? 0)
                let mediaReach = CGFloat(mediaData?.insights?.data[0]?.values[0]?.value ?? 0)

                sumLikesCommentsArray.append(mediaSumLikesComment)
                impressions.append(mediaImpressions)
                reachArray.append(mediaReach)
            } else {
                print("media has no insights")
            }
            
            //time_stamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            if let stringDate = mediaData?.timestamp {
                let date = dateFormatter.date(from:(stringDate))
                times.append(date?.timeIntervalSince1970)
            }
        }
        
        let engagementRateFollowers = getEngagementByFollowerRates(
            engagementArray: sumLikesCommentsArray, followersCount: profileResponse.followers_count)
        let engagementRateImpressions = getEngagementByImpressionRates(
            engagementArray: sumLikesCommentsArray, impressions: impressions)
        let engagementRateReach = getEngagementByReachRates(
            engagementArray: sumLikesCommentsArray, reachArray: reachArray)

        return(
            .init(
                likeArray: likeArray,
                commentArray: commentArray,
                engagementRateFollowers: rawInsights ? sumLikesCommentsArray : engagementRateFollowers,
                times: times,
                captions: captions,
                engagementRateImpressions: rawInsights ? impressions : engagementRateImpressions,
                engagementRateReach: rawInsights ? reachArray : engagementRateReach))
    }
    
    private static func getEngagementByFollowerRates(engagementArray: [CGFloat], followersCount: Int?) -> [CGFloat] {
        var engFollowers  = [CGFloat]()
        if let followersCount, followersCount != 0 {
            engFollowers = engagementArray.map { ($0 * 100.0 / CGFloat(followersCount)) }
        } else {
            engFollowers = engagementArray.map { ($0 * 0) }
        }
        return engFollowers
    }
    
    private static func getEngagementByImpressionRates(engagementArray: [CGFloat], impressions: [CGFloat]) -> [CGFloat] {
        var engImpressions = [CGFloat]()
        impressions.indices.forEach {
            if impressions[$0] == 0 {
                engImpressions.append(0) //append 0 when Nan
            } else {
                engImpressions.append(engagementArray[$0]*100/CGFloat(impressions[$0]))
            }
        }
        return engImpressions
    }
    
    private static func getEngagementByReachRates(engagementArray: [CGFloat], reachArray: [CGFloat]) -> [CGFloat] {
        var engReach = [CGFloat]()
        reachArray.indices.forEach {
            if reachArray[$0] == 0 {
                engReach.append(0) //append 0 when Nan
            } else {
                engReach.append(engagementArray[$0]*100/CGFloat(reachArray[$0]))
            }
        }
        return engReach
    }
}
