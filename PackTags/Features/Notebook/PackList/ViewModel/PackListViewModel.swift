import Foundation

private enum Strings {
    static let oneHashtag = "1 Hashtag".localized()
    static let zeroHashtags = "0 Hashtags".localized()
    static let more = "more".localized()
}

final class PackListViewModel {
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    let theme: ThemeCD
    private(set) var packs: [String] = []

    init(theme: ThemeCD, repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.theme = theme
        self.repository = repository
        self.settings = settings
    }

    func loadPacks() {
        guard let content = theme.content else {
            packs = []
            return
        }
        packs = TagPackFormatter.packs(from: content, tagsPerPack: settings.tagsPerPack)
    }

    struct PackRow {
        let firstTag: String?
        let badge: String
    }

    /// Presentation data for one pack row; nil when the index is stale.
    func packRow(at index: Int) -> PackRow? {
        guard packs.indices.contains(index) else { return nil }
        let tags = packs[index].components(separatedBy: " ").filter { !$0.isEmpty }

        let badge: String
        switch tags.count {
        case 0: badge = " \(Strings.zeroHashtags) "
        case 1: badge = " \(Strings.oneHashtag) "
        case let count: badge = " + \(count - 1) \(Strings.more) "
        }
        return PackRow(firstTag: tags.first, badge: badge)
    }

    struct PostCopyAction {
        let shouldMovePackToBottom: Bool
        /// Non-nil when the app should redirect to the user's Instagram.
        let instagramAppURL: String?
        let instagramWebURL: String?
    }

    enum InstagramRedirectToggle {
        case promptForUsername
        case enabled(username: String)
        case disabled(username: String)
    }

    func postCopyAction() -> PostCopyAction {
        let username = settings.openInstagramAfterCopy ? (settings.instagramUsername ?? "") : nil
        return PostCopyAction(
            shouldMovePackToBottom: !settings.keepPacksOrder,
            instagramAppURL: username.map { "instagram://user?username=\($0)" },
            instagramWebURL: username.map { "https://instagram.com/\($0)" }
        )
    }

    func toggleInstagramRedirect() -> InstagramRedirectToggle {
        let username = settings.instagramUsername ?? ""
        guard !username.isEmpty else { return .promptForUsername }

        settings.openInstagramAfterCopy.toggle()
        return settings.openInstagramAfterCopy ? .enabled(username: username) : .disabled(username: username)
    }

    func saveInstagramUsername(_ rawName: String) -> String {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.instagramUsername = name
        settings.openInstagramAfterCopy = true
        return name
    }

    func movePack(at index: Int) {
        guard index < packs.count else { return }
        let element = packs.remove(at: index)
        packs.append(element)
        theme.content = packs.joined(separator: " ")
        repository.save()
    }
}
