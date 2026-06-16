import Foundation

final class SettingsViewModel {
    /// Presentation the view performs on the user's behalf. The view model
    /// decides *what* (copy, URLs); the view controller decides *how* (present).
    enum ViewEvent {
        case editInstagram(message: String, placeholder: String)
        case shareApp(url: URL)
        case rateApp(writeReviewURL: URL)
        case openWebPage(url: URL)
        case contactSupport
        case openExternalApp(appURL: String, webURL: String)
    }

    private enum Links {
        static let appStore = "https://apps.apple.com/app/id1579377025"
        static let instagramApp = "instagram://user?username=packtags.app"
        static let instagramWeb = "https://instagram.com/packtags.app"
    }

    private enum Strings {
        static let username = "Username".localized()
        static let enterUsername = "Enter Username".localized()
        static let editUsername = "Edit Username".localized()
    }

    /// Set by the view; the view model calls it to drive control-driven presentation.
    var onViewEvent: ((ViewEvent) -> Void)?

    /// The settings catalog the view renders. Built once, lazily, so the action
    /// closures can capture a fully-initialised view model.
    ///
    /// Intentionally not reactive: the only mutable rows are switches, which write
    /// straight through `onToggle`, and a fresh view model is built on every visit to
    /// Settings. Nothing on-screen can go stale, so there is no `onUpdate`/refresh loop.
    lazy var sections: [SettingsSection] = SettingsSections.make(actions: makeActions(), settings: settings)

    private let settings: any AppSettingsProtocol
    private let navigation: SettingsNavigation

    init(settings: any AppSettingsProtocol, navigation: SettingsNavigation) {
        self.settings = settings
        self.navigation = navigation
    }

    func saveInstagramUsername(_ rawName: String) {
        settings.instagramUsername = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var instagramUsername: String {
        settings.instagramUsername ?? ""
    }

    private func makeActions() -> SettingsActions {
        SettingsActions(
            editInstagramUsername: { [weak self] in self?.requestEditInstagram() },
            openFacebookSetup: navigation.openFacebookSetup,
            showQuantityPicker: navigation.openQuantityPicker,
            replayOnboarding: navigation.replayOnboarding,
            openSetupInfo: navigation.openSetupInfo,
            openWebPage: { [weak self] urlString in
                guard let url = URL(string: urlString) else { return }
                self?.onViewEvent?(.openWebPage(url: url))
            },
            openOurInstagram: { [weak self] in
                self?.onViewEvent?(.openExternalApp(appURL: Links.instagramApp, webURL: Links.instagramWeb))
            },
            shareApp: { [weak self] in
                guard let url = URL(string: Links.appStore) else { return }
                self?.onViewEvent?(.shareApp(url: url))
            },
            rateApp: { [weak self] in
                guard let url = Self.writeReviewURL() else { return }
                self?.onViewEvent?(.rateApp(writeReviewURL: url))
            },
            contactSupport: { [weak self] in self?.onViewEvent?(.contactSupport) }
        )
    }

    private func requestEditInstagram() {
        let username = instagramUsername
        let message = username.isEmpty ? Strings.username : username
        let placeholder = username.isEmpty ? Strings.enterUsername : Strings.editUsername
        onViewEvent?(.editInstagram(message: message, placeholder: placeholder))
    }

    private static func writeReviewURL() -> URL? {
        guard let base = URL(string: Links.appStore),
              var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = [URLQueryItem(name: "action", value: "write-review")]
        return components.url
    }
}
