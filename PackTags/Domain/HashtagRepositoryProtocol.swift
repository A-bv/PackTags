import Foundation

/// Persists the hashtags searched in Smart Hashtags so the saved list survives launches.
protocol HashtagRepositoryProtocol {
    /// Records a searched hashtag as one unit of work: replaces an existing entry with
    /// the same title, drops entries past Instagram's 7-day window, and persists.
    func recordSearch(_ hashtag: String)
}
