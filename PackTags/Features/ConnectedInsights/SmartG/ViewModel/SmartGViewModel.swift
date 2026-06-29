import SwiftUI
import InstagramGraph

@MainActor
@Observable
final class SmartGViewModel {
    @ObservationIgnored private let gateway: any ConnectedInsightsGatewayProtocol
    @ObservationIgnored private let searchTimeout: Double

    private enum Strings {
        static let defaultHashtag = "travel"
    }

    private enum Constants {
        static let searchTimeout: Double = 15
    }

    var dataMedias: [InstagramPost] = []
    var computedData: [SmartGModel] = []
    var topHashtags: [String] = []
    var topHashtagsCount: [Int] = []

    var loading = true
    /// A search threw (network / server / timeout) — distinct from one that found nothing.
    var isErrorState = false
    var showingPopover = false
    var showingAlert = false
    var hashtagEntry = ""

    private(set) var hasSearched = false

    /// A search completed but matched nothing — likely a mistyped hashtag, not a failure.
    var hasNoResults: Bool { hasSearched && !isErrorState && computedData.isEmpty }

    private var searchedHashtag = ""
    private var lastSearchedHashtag = Strings.defaultHashtag
    /// Bumped per search, so a slow earlier search can tell it's been superseded and not
    /// overwrite a newer one.
    private var searchGeneration = 0

    init(gateway: any ConnectedInsightsGatewayProtocol, searchTimeout: Double = Constants.searchTimeout) {
        self.gateway = gateway
        self.searchTimeout = searchTimeout
    }

    func loadDefaultFeed() async {
        await runSearch(hashtag: Strings.defaultHashtag)
    }

    /// Returns false when the entry is unchanged and its results are already showing.
    func submitSearch() async -> Bool {
        let newEntry = hashtagEntry.filter { $0 != "#" }
        guard searchedHashtag != newEntry else { return false }

        searchedHashtag = newEntry
        await runSearch(hashtag: newEntry)
        return true
    }

    func retry() async {
        await runSearch(hashtag: lastSearchedHashtag)
    }
}

extension SmartGViewModel {
    private func runSearch(hashtag: String) async {
        searchGeneration += 1
        let generation = searchGeneration
        lastSearchedHashtag = hashtag
        loading = true
        isErrorState = false

        do {
            try await withThrowingTimeout(seconds: searchTimeout) { [self] in
                try await loadPosts(hashtag: hashtag, generation: generation)
            }
        } catch is CancellationError {
            return // screen dismissed — leave state untouched
        } catch {
            guard generation == searchGeneration else { return }
            AppLogger.insights.error("Hashtag search failed: \(error.localizedDescription, privacy: .private)")
            hasSearched = true
            // Couldn't reach Instagram → offer retry; any other failure → treat as "no results".
            if Self.isConnectivityFailure(error) {
                isErrorState = true
            } else {
                resetResults()
            }
        }
        guard generation == searchGeneration else { return }
        loading = false
    }

    private static func isConnectivityFailure(_ error: Error) -> Bool {
        if error is TimedOutError { return true }
        if case InstagramGraphServiceError.networkError = error { return true }
        return false
    }

    private func resetResults() {
        dataMedias = []
        computedData = []
        topHashtags = []
        topHashtagsCount = []
    }

    /// A separate `@MainActor` method, not inlined in the task-group child, so the
    /// non-Sendable `[InstagramPost]` stays out of the child's region analysis — inlining a
    /// non-Sendable collection there trips the region-based isolation checker.
    private func loadPosts(hashtag: String, generation: Int) async throws {
        let interval = AppLogger.signposter.beginInterval("HashtagSearch")
        defer { AppLogger.signposter.endInterval("HashtagSearch", interval) }

        let posts = try await gateway.searchHashtag(searchedHashtag: hashtag)
        try Task.checkCancellation()
        guard generation == searchGeneration else { return } // superseded — drop stale results
        dataMedias = posts
        processSmartGModel()
        hasSearched = true
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
