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
        /// Caps a stalled search (e.g. connectivity lost mid-load) so the screen falls
        /// back to the failure + retry state instead of spinning indefinitely.
        static let searchTimeout: Double = 15
    }

    var dataMedias: [InstagramPost] = []
    var computedData: [SmartGModel] = []
    var topHashtags: [String] = []
    var topHashtagsCount: [Int] = []

    // UI state shared by SmartGView and the interaction bar.
    var loading = true
    /// True when the last search threw (network / server / timeout). The view shows a
    /// failure + retry state — distinct from a successful search that found nothing.
    var isErrorState = false
    var showingPopover = false
    var showingAlert = false
    var hashtagEntry = ""

    /// True once a search has completed, so the view can tell an empty *result* apart
    /// from the initial pre-load state.
    private(set) var hasSearched = false

    /// A search succeeded but returned nothing to show — the user likely mistyped the
    /// hashtag, as opposed to a request failure.
    var hasNoResults: Bool { hasSearched && !isErrorState && computedData.isEmpty }

    private var searchedHashtag = ""
    /// The hashtag of the most recent search, replayed by `retry()`.
    private var lastSearchedHashtag = Strings.defaultHashtag
    /// Bumped on every search; lets a slow earlier search detect it has been superseded and
    /// drop its (now stale) results instead of overwriting a newer search.
    private var searchGeneration = 0

    init(gateway: any ConnectedInsightsGatewayProtocol, searchTimeout: Double = Constants.searchTimeout) {
        self.gateway = gateway
        self.searchTimeout = searchTimeout
    }

    /// The initial feed shown before the user searches anything.
    func loadDefaultFeed() async {
        await runSearch(hashtag: Strings.defaultHashtag)
    }

    /// Runs a search when the entry differs from the last one searched.
    /// Returns false when that hashtag's results were already showing.
    func submitSearch() async -> Bool {
        let newEntry = hashtagEntry.filter { $0 != "#" }
        guard searchedHashtag != newEntry else { return false }

        searchedHashtag = newEntry
        await runSearch(hashtag: newEntry)
        return true
    }

    /// Re-runs the most recent search after a failure.
    func retry() async {
        await runSearch(hashtag: lastSearchedHashtag)
    }
}

extension SmartGViewModel {
    /// Runs a search behind `withThrowingTimeout`, so a stalled request falls back to the
    /// failure state and a parent `.task` cancelling stops it cleanly. Tags the run with a
    /// generation so a slow earlier search can't overwrite a newer one's results or state.
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
            // Parent cancelled (the screen was dismissed) — leave state untouched.
            return
        } catch {
            guard generation == searchGeneration else { return } // a newer search supersedes us
            AppLogger.insights.error("Hashtag search failed: \(error.localizedDescription, privacy: .private)")
            hasSearched = true
            if Self.isConnectivityFailure(error) {
                isErrorState = true   // couldn't reach Instagram → "check your connection" + retry
            } else {
                // The request reached Instagram but the hashtag couldn't be resolved (unknown
                // tag, API or decoding error). Present it as "no results", not a connection
                // problem, so the user is told to check their entry.
                resetResults()
            }
        }
        guard generation == searchGeneration else { return } // a newer search owns `loading`
        loading = false
    }

    /// True only for failures that mean we couldn't reach Instagram (no network, or our own
    /// timeout) — the case that warrants "check your connection" + retry. Any other thrown
    /// error means the request got through but the hashtag couldn't be resolved, which the
    /// view presents as "no results / check your entry".
    private static func isConnectivityFailure(_ error: Error) -> Bool {
        if error is TimedOutError { return true }
        if case InstagramGraphServiceError.networkError = error { return true }
        return false
    }

    /// Clears the displayed results so the "check your entry" state shows after a failed
    /// search, rather than leaving a previous search's results on screen.
    private func resetResults() {
        dataMedias = []
        computedData = []
        topHashtags = []
        topHashtagsCount = []
    }

    /// Fetches and applies posts for `hashtag`. Takes the hashtag as an immutable parameter
    /// (not the shared `lastSearchedHashtag`) so overlapping searches each request their own
    /// term, and drops the result if a newer search has started since. Kept as a plain
    /// `@MainActor` method — not inlined in the task-group child — so the non-Sendable
    /// `[InstagramPost]` stays out of that child closure's region analysis; inlining a
    /// non-Sendable *collection* there trips the region-based isolation checker.
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
