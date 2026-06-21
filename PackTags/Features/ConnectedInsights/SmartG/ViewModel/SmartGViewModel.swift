import SwiftUI
import InstagramGraph

@MainActor
@Observable
final class SmartGViewModel {
    @ObservationIgnored private let gateway: any ConnectedInsightsGatewayProtocol

    private enum Strings {
        static let defaultHashtag = "travel"
    }

    var dataMedias: [InstagramPost] = []
    var computedData: [SmartGModel] = []
    var topHashtags: [String] = []
    var topHashtagsCount: [Int] = []

    // UI state shared by SmartGView and the interaction bar.
    var loading = true
    var isErrorState = false
    var showingPopover = false
    var showingAlert = false
    var hashtagEntry = ""

    private var searchedHashtag = ""

    init(gateway: any ConnectedInsightsGatewayProtocol) {
        self.gateway = gateway
    }

    /// The initial feed shown before the user searches anything.
    func loadDefaultFeed() async {
        loading = true
        isErrorState = await fetch(hashtag: Strings.defaultHashtag)
        loading = false
    }

    /// Runs a search when the entry differs from the last one searched.
    /// Returns false when that hashtag's results were already showing.
    func submitSearch() async -> Bool {
        let newEntry = hashtagEntry.filter { $0 != "#" }
        guard searchedHashtag != newEntry else { return false }

        searchedHashtag = newEntry
        loading = true
        isErrorState = await fetch(hashtag: newEntry)
        loading = false
        return true
    }
}

extension SmartGViewModel {
    /// Loads posts for the hashtag and recomputes the model.
    /// Returns true when the search failed and the error state should show.
    private func fetch(hashtag: String) async -> Bool {
        do {
            dataMedias = try await gateway.searchHashtag(searchedHashtag: hashtag)
            processSmartGModel()
            return false
        } catch {
            AppLogger.insights.error("Hashtag search failed: \(error.localizedDescription, privacy: .public)")
            return true
        }
    }

    func processSmartGModel() {
        var processedSmartGModels = [SmartGModel]()
        var hashtagsFullList: [String] = []

        for dataMedia in dataMedias {
            let hashtags = dataMedia.caption.map(HashtagParser.parse) ?? []
            processedSmartGModels.append(SmartGModel(hashtags: hashtags))
            hashtagsFullList += hashtags
        }

        self.computedData = processedSmartGModels

        let counts = hashtagsFullList.reduce(into: [String: Int]()) { counts, hashtag in
            counts[hashtag, default: 0] += 1
        }
        let top = counts.sorted { $0.value > $1.value }.prefix(10)
        self.topHashtags = top.map(\.key)
        self.topHashtagsCount = top.map(\.value)
    }
}
