import Foundation
import Observation
import InstagramGraph

/// The engagement dimension the analytics screen is showing. Replaces the old
/// magic-`Int` mode: the raw value indexes the parallel rate arrays the
/// transformer builds (followers / reach / impressions), so it is always valid.
enum AnalyticsMetric: Int, CaseIterable {
    case engagement
    case reach
    case impressions

    func next() -> AnalyticsMetric {
        AnalyticsMetric(rawValue: rawValue + 1) ?? .engagement
    }
}

private enum Strings {
    static let likes = "Likes".localized()
    static let comments = "Comments".localized()
    static let average = "Average".localized()
    static let selection = "Selection".localized()
}

@MainActor
@Observable
final class AnalyticsViewModel {
    @ObservationIgnored let gateway: any ConnectedInsightsGatewayProtocol

    var metric: AnalyticsMetric = .engagement
    var rawInsights = true

    // MARK: - Live data
    var transformedProfile: TransformedProfileModel?
    var profile: Profile?

    var overviewSectionData = [
        AnalyticsOverviewModel(
            id: 0,
            title: Strings.likes,
            value: "0",
            systemImageName: "suit.heart.fill"),
        AnalyticsOverviewModel(
            id: 1,
            title: Strings.comments,
            value: "0",
            systemImageName: "text.bubble.fill")]

    var circlesData = [
        Circles(
            id: 0,
            title: Strings.average,
            value: 0,
            maxValue: 0),
        Circles(
            id: 1,
            title: Strings.selection,
            value: 0,
            maxValue: 0)
    ]

    var barChartData: [BarChartPost] = [BarChartPost(id: 0, post: "", rate: 0, barHeight: 0)]

    // MARK: - Init
    init(gateway: any ConnectedInsightsGatewayProtocol) {
        self.gateway = gateway
    }
}
