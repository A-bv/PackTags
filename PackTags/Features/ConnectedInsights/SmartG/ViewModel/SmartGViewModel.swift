import SwiftUI
import InstagramGraph

@MainActor
@Observable
final class SmartGViewModel {
    @ObservationIgnored let gateway: any ConnectedInsightsGatewayProtocol

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
    func processSmartGModel() {
        var processedSmartGModels = [SmartGModel]()
        var hashtagsFullList: [String] = []

        for dataMedia in dataMedias {
            let hashtags = dataMedia.caption?.detectHashtags() ?? []
            processedSmartGModels.append(SmartGModel(hashtags: hashtags))
            hashtagsFullList += hashtags
        }

        self.computedData = processedSmartGModels

        let hashtagsHistogram = hashtagsFullList.histogram.sorted { $0.1 > $1.1 }.prefix(10)
        self.topHashtags = hashtagsHistogram.map({ $0.key })
        self.topHashtagsCount = hashtagsHistogram.map({ $0.value })
    }
}
