import SwiftUI
import Combine
import InstagramGraph

private enum Strings {
    static let likes = "Likes".localized()
    static let comments = "Comments".localized()
    static let average = "Average".localized()
    static let selection = "Selection".localized()
}

@MainActor
final class AnalyticsViewModel: ObservableObject {
    let gateway: any ConnectedInsightsGatewayProtocol

    @Published var mode: Int = 0
    @Published var rawInsights: Bool = true

    //MARK: - Live Variables
    @Published var processedJson : TransformedProfileModel?
    @Published var jsonOfficial : Profile? //Api Graph
    @Published var overviewSectionData = [
        AnalyticsOverviewModel(
            id: 0,
            title: Strings.likes,
            value: "0",
            image: Image(systemName: "suit.heart.fill")),
        AnalyticsOverviewModel(
            id: 1,
            title: Strings.comments,
            value: "0",
            image: Image(systemName: "text.bubble.fill"))]
    
    @Published var circlesData = [
        Circles(
            id: 0,
            title: Strings.average,
            value: 0,
            maxValue: 0,
            color: .blue),
        Circles(
            id: 1,
            title: Strings.selection,
            value: 0,
            maxValue: 0,
            color: .blue)
    ]

    @Published var barChartData: [BarChartPost] = [BarChartPost(id: 0, post: "", rate: 0, barHeight: 0)]
    
    //MARK: - Init
    init(gateway: any ConnectedInsightsGatewayProtocol) {
        self.gateway = gateway
    }
}
