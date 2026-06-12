import Foundation
import InstagramGraph

extension SmartGViewModel {
    /// Loads posts for the hashtag and recomputes the model.
    /// Returns true when the search failed and the error state should show.
    func fetch(hashtag: String) async -> Bool {
        do {
            dataMedias = try await gateway.searchHashtag(searchedHashtag: hashtag)
            processSmartGModel()
            return false
        } catch {
            AppLogger.insights.error("Hashtag search failed: \(error.localizedDescription, privacy: .public)")
            return true
        }
    }
}
