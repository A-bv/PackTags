import Foundation
import InstagramGraph

// Analytics
extension AnalyticsViewModel {
    /// Re-runs the transformation after the mode or raw/rate toggle changes,
    /// using the profile already in memory — no network round trip.
    func refreshFromCurrentProfile() {
        guard let jsonOfficial else { return }
        load(profileJson: jsonOfficial)
    }

    func load() async {
        do {
            let profileJson = try await gateway.loadProfileForAnalytics(mediaLimit: 12)
            load(profileJson: profileJson)
        } catch {
            AppLogger.insights.error("Failed to load analytics profile: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func load(profileJson: Profile) {
        jsonOfficial = profileJson
        processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson, mode: mode, rawInsights: rawInsights)
        updateData()
    }
    
    private func updateData() {
        fillGraphData()
        fillOverviewSectionData()
    }
    
    private func fillGraphData() {
        guard let rates = processedJson?.rates, !rates.isEmpty else {
            AppLogger.insights.info("No engagement rates available.")
            return
        }
        
        let maxRate = getMaxRate()
        barChartData = rates.enumerated().map { index, rate in
            let rate = rate ?? 0
            return BarChartPost(
                id: index,
                post: "\(index + 1)",
                rate: rate,
                barHeight: (rate / maxRate) * 50 + 5)
        }
    }
    
    private func fillOverviewSectionData() {
        guard let rates = processedJson?.rates, !rates.isEmpty else {
            return
        }

        overviewSectionData[0].value = StringFormatter.formatNum(value: processedJson?.averageLikes ?? 0)
        overviewSectionData[1].value = StringFormatter.formatNum(value: processedJson?.averageComments ?? 0)

        circlesData[1].value = CGFloat(rates[0] ?? 0)
        circlesData[1].maxValue = getMaxRate()

        let avgEngagement: CGFloat = CGFloat(processedJson?.averageRate ?? 0)
        circlesData[0].value = avgEngagement
        circlesData[0].maxValue = avgEngagement
    }
    
    private func getMaxRate() -> CGFloat {
        guard let max = processedJson?.maxRate, max != 0 else { return 1 }
        return max
    }
}
