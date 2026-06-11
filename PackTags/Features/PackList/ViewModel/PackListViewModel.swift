import Foundation

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

    struct PostCopyAction {
        let shouldMovePackToBottom: Bool
        /// Non-nil when the app should redirect to this Instagram profile.
        let instagramUsername: String?
    }

    enum InstagramRedirectToggle {
        case promptForUsername
        case enabled(username: String)
        case disabled(username: String)
    }

    func postCopyAction() -> PostCopyAction {
        PostCopyAction(
            shouldMovePackToBottom: !settings.keepPacksOrder,
            instagramUsername: settings.openInstagramAfterCopy ? (settings.instagramUsername ?? "") : nil
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
