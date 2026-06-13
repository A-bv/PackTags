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
        guard let metrics = computeMetrics(profileResponse: response, rawInsights: rawInsights) else { return nil }

        let averageLikes = averageInt(metrics.likeArray)
        let averageComments = averageInt(metrics.commentArray)

        let engagementRates = [
            metrics.engagementRateFollowers,
            metrics.engagementRateReach,
            metrics.engagementRateImpressions]

        var averageRate = [CGFloat?]()
        var maxRate = [CGFloat?]()

        for er in engagementRates {
            averageRate.append(averageCGFloat(er))
            maxRate.append(er.reduce(CGFloat.leastNormalMagnitude, { max($0, CGFloat($1)) }))
        }

        let safeMode = min(mode, engagementRates.count - 1)

        return TransformedProfileModel(
            username: response.username,
            isPrivateProfile: false,
            totalLikes: metrics.likeArray.reduce(0, +),
            totalComments: metrics.commentArray.reduce(0, +),
            averageLikes: averageLikes,
            averageComments: averageComments,
            rates: engagementRates[safeMode],
            postTimes: metrics.times,
            averageRate: averageRate[safeMode],
            maxRate: maxRate[safeMode],
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

            // Look metrics up by name, not array position: the Graph response
            // may reorder or omit metrics. "views" is Meta's replacement for the
            // deprecated "impressions" metric (still surfaced as Impressions in
            // the UI). All three must be present to keep the parallel arrays
            // aligned.
            let metrics = mediaData?.insights?.data ?? []
            func metricValue(_ name: String) -> CGFloat? {
                metrics.first { $0.name == name }.map { CGFloat($0.values.first?.value ?? 0) }
            }

            if let reach = metricValue("reach"),
               let views = metricValue("views"),
               let interactions = metricValue("total_interactions") {
                reachArray.append(reach)
                impressions.append(views)
                sumLikesCommentsArray.append(interactions)
            } else {
                AppLogger.insights.debug("Media item missing reach/views/total_interactions insights.")
            }

            times.append(mediaData?.timestamp?.timeIntervalSince1970)
        }

        let engagementRateFollowers = getEngagementByFollowerRates(
            engagementArray: sumLikesCommentsArray, followersCount: profileResponse.followersCount)
        let engagementRateImpressions = rates(engagement: sumLikesCommentsArray, dividedBy: impressions)
        let engagementRateReach = rates(engagement: sumLikesCommentsArray, dividedBy: reachArray)

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
        guard let followersCount, followersCount != 0 else {
            return engagementArray.map { _ in 0 }
        }
        return engagementArray.map { $0 * 100.0 / CGFloat(followersCount) }
    }

    /// Per-post engagement percentage; 0 where the denominator is 0.
    private static func rates(engagement: [CGFloat], dividedBy denominators: [CGFloat]) -> [CGFloat] {
        denominators.indices.map {
            denominators[$0] == 0 ? 0 : engagement[$0] * 100 / denominators[$0]
        }
    }
}
