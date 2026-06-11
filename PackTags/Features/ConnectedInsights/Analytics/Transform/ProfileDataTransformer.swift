//
//  processJsonAPIGraph.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import InstagramGraph

enum DataTransformer {}

extension DataTransformer {
    enum ProfileDataTransformer {}
}

extension DataTransformer.ProfileDataTransformer {
    static func transform(
        response: Profile,
        mode: Int = 0,
        rawInsights: Bool = true
    ) -> TransformedProfileModel? {
        let top = response

        guard let metrics = computeMetrics(profileResponse: response, rawInsights: rawInsights) else { return nil }

        let avg0 = averageInt(metrics.likeArray)
        let avg1 = averageInt(metrics.commentArray)

        let engagementRates = [
            metrics.engagementRateFollowers,
            metrics.engagementRateReach,
            metrics.engagementRateImpressions]

        var avg2 = [CGFloat?]()
        var maxR = [CGFloat?]()

        for er in engagementRates {
            avg2.append(averageCGFloat(er))
            maxR.append(er.reduce(CGFloat.leastNormalMagnitude, { max($0, CGFloat($1)) }))
        }

        let safeMode = min(mode, engagementRates.count - 1)

        return TransformedProfileModel(
            usr: top.username,
            isPv: false,
            sum0: metrics.likeArray.reduce(0, +),
            sum1: metrics.commentArray.reduce(0, +),
            avg0: avg0,
            avg1: avg1,
            rates: engagementRates[safeMode],
            pTimes: metrics.times,
            avg2: avg2[safeMode],
            maxR: maxR[safeMode],
            captions: metrics.captions)
    }

    private static func averageInt(_ array: [Int]) -> Double {
        guard !array.isEmpty else { return 0 }
        return Double(array.reduce(0, +)) / Double(array.count)
    }

    private static func averageCGFloat(_ array: [CGFloat]) -> CGFloat {
        guard !array.isEmpty else { return 0 }
        return array.reduce(0, +) / CGFloat(array.count)
    }
}

extension DataTransformer.ProfileDataTransformer {
    static private func computeMetrics(profileResponse: Profile, rawInsights: Bool) -> SubTransformedProfileModel? {
        var likeArray = [Int]()
        var commentArray = [Int]()
        var sumLikesCommentsArray = [CGFloat]()
        var impressions = [CGFloat]()
        var reachArray = [CGFloat]()
        var times = [Double?]()
        var captions = [String?]()
    
        guard let numberOfMedias = profileResponse.media?.data.count else {
            AppLogger.insights.info("Profile has no media to transform.")
            return nil
        }
        
        for i in 0..<numberOfMedias {
            let mediaData = profileResponse.media?.data[i]
            
            likeArray.append(mediaData?.likeCount ?? 0)
            commentArray.append(mediaData?.commentsCount ?? 0)
            captions.append(mediaData?.caption ?? "")

            if let insightsData = mediaData?.insights?.data, insightsData.count > 2 {
                let mediaSumLikesComment = CGFloat(insightsData[2].values.first?.value ?? 0)
                let mediaImpressions = CGFloat(insightsData[1].values.first?.value ?? 0)
                let mediaReach = CGFloat(insightsData[0].values.first?.value ?? 0)

                sumLikesCommentsArray.append(mediaSumLikesComment)
                impressions.append(mediaImpressions)
                reachArray.append(mediaReach)
            } else {
                AppLogger.insights.debug("Media item has no insights data.")
            }

            times.append(mediaData?.timestamp?.timeIntervalSince1970)
        }

        let engagementRateFollowers = getEngagementByFollowerRates(
            engagementArray: sumLikesCommentsArray, followersCount: profileResponse.followersCount)
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
