import SwiftUI
import Combine
import InstagramGraph

class AnalyticsViewModel: ObservableObject {
    private enum Strings {
        static let likes = "Likes".localized()
        static let comments = "Comments".localized()
        static let average = "Average".localized()
        static let selection = "Selection".localized()
    }

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
            maxValue: 0,
            color: .blue,
            image: Image(systemName: "suit.heart.fill")),
        AnalyticsOverviewModel(
            id: 1,
            title: Strings.comments,
            value: "0",
            maxValue: 0,
            color: .blue,
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
    init(gateway: any ConnectedInsightsGatewayProtocol = UnavailableConnectedInsightsGateway()) {
        self.gateway = gateway
        self.loadDataForAnalyticsView()
    }
    
    private func loadDataForAnalyticsView() {
        canRefresh() == true ? getOnlineJsonAPIGraph() : getJsonFromDir()
    }
}

extension AnalyticsViewModel {
    private enum Constants {
        static let minimumSecondsBetweenRefreshes: TimeInterval = 5
    }

    func canRefresh() -> Bool {
        let defaults = UserDefaults.standard
        guard let lastRefresh = defaults.object(forKey: SettingsKey.lastStatsRefresh) as? Date else { return true }

        guard lastRefresh + Constants.minimumSecondsBetweenRefreshes <= Date() else { return false }

        defaults.set(Date(), forKey: SettingsKey.lastStatsRefresh)
        return true
    }
}
