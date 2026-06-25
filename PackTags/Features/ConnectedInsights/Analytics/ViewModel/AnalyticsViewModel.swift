import Foundation
import Observation
import InstagramGraph

@MainActor
@Observable
final class AnalyticsViewModel {
    private enum Strings {
        static let likes = "Likes".localized()
        static let comments = "Comments".localized()
        static let average = "Average".localized()
        static let selection = "Selection".localized()
    }

    private enum Constants {
        /// Caps a stalled request (e.g. connectivity lost mid-load) so the screen falls
        /// back to the error + retry state instead of spinning indefinitely.
        static let loadTimeout: Double = 15
    }

    @ObservationIgnored private let gateway: any ConnectedInsightsGatewayProtocol
    @ObservationIgnored private let loadTimeout: Double

    var metric: AnalyticsMetric = .engagement
    var rawInsights = true

    // MARK: - Live data
    var transformedProfile: TransformedProfileModel?
    var profile: Profile?
    /// True when the last `load()` threw; the view shows an error + retry instead of
    /// spinning forever.
    var loadFailed = false

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
    init(gateway: any ConnectedInsightsGatewayProtocol, loadTimeout: Double = Constants.loadTimeout) {
        self.gateway = gateway
        self.loadTimeout = loadTimeout
    }
}

// MARK: - Data loading & transformation

extension AnalyticsViewModel {
    /// Re-runs the transformation after the mode or raw/rate toggle changes,
    /// using the profile already in memory — no network round trip.
    func refreshFromCurrentProfile() {
        guard let profile else { return }
        load(profile: profile)
    }

    func load() async {
        loadFailed = false

        // Race the request against a timeout in a structured group: a stalled load
        // falls back to the error state, and because the group is structured, the
        // parent (e.g. SwiftUI `.task`) cancelling propagates here — a cancelled
        // load can't mutate the view model after the screen is gone. The request
        // child is `@MainActor`, so the non-Sendable Profile never crosses an
        // isolation boundary; the group's result is `Void`, which is `Sendable`.
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor [self] in
                    let profile = try await gateway.loadProfileForAnalytics(mediaLimit: 12)
                    try Task.checkCancellation()
                    load(profile: profile)
                }
                group.addTask { [loadTimeout] in
                    try await Task.sleep(for: .seconds(loadTimeout))
                    throw LoadTimedOut()
                }
                try await group.next()   // whichever finishes first wins
                group.cancelAll()        // cancel the loser
            }
        } catch is CancellationError {
            // Parent cancelled (the screen was dismissed) — leave state untouched.
        } catch {
            AppLogger.insights.error("Failed to load analytics profile: \(error.localizedDescription, privacy: .private)")
            loadFailed = true
        }
    }

    private struct LoadTimedOut: Error {}

    private func load(profile: Profile) {
        self.profile = profile
        transformedProfile = ProfileDataTransformer.transform(response: profile, metric: metric, rawInsights: rawInsights)
        updateData()
    }

    private func updateData() {
        fillGraphData()
        fillOverviewSectionData()
    }

    private func fillGraphData() {
        guard let rates = transformedProfile?.rates, !rates.isEmpty else {
            AppLogger.insights.info("No engagement rates available.")
            return
        }

        let maxRate = getMaxRate()
        barChartData = rates.enumerated().map { index, rate in
            let rate = rate ?? 0
            return BarChartPostModel(
                id: index,
                post: "\(index + 1)",
                rate: rate,
                barHeight: (rate / maxRate) * 50 + 5)
        }
    }

    private func fillOverviewSectionData() {
        guard let rates = transformedProfile?.rates, !rates.isEmpty else {
            return
        }

        overviewSectionData[0].value = MetricFormatter.compact(transformedProfile?.averageLikes ?? 0)
        overviewSectionData[1].value = MetricFormatter.compact(transformedProfile?.averageComments ?? 0)

        circlesData[1].value = CGFloat(rates[0] ?? 0)
        circlesData[1].maxValue = getMaxRate()

        let avgEngagement: CGFloat = CGFloat(transformedProfile?.averageRate ?? 0)
        circlesData[0].value = avgEngagement
        circlesData[0].maxValue = avgEngagement
    }

    private func getMaxRate() -> CGFloat {
        guard let max = transformedProfile?.maxRate, max != 0 else { return 1 }
        return max
    }
}
