import Foundation

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
