import Foundation
import Observation
import InstagramGraph

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
        CircleGaugeModel(
            id: 0,
            title: Strings.average,
            value: 0,
            maxValue: 0),
        CircleGaugeModel(
            id: 1,
            title: Strings.selection,
            value: 0,
            maxValue: 0)
    ]

    var barChartData: [BarChartPostModel] = [BarChartPostModel(id: 0, post: "", rate: 0, barHeight: 0)]

    // MARK: - Init
    init(gateway: any ConnectedInsightsGatewayProtocol) {
        self.gateway = gateway
    }
}
