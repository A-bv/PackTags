import UIKit

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
        static let tricksAndTips = "https://sites.google.com/view/packtags-tricks-tips/accueil"
        static let privacyPolicy = "https://sites.google.com/view/packtags-privacy-policy/accueil"
        static let termsAndConditions = "https://sites.google.com/view/packtagstc/accueil"
        static let disclaimer = "https://sites.google.com/view/packtagsdisclaimer/accueil"
    }

    private enum Strings {
        static let username = "Username".localized()
        static let enterUsername = "Enter Username".localized()
        static let editUsername = "Edit Username".localized()
        static let account = "Account".localized()
        static let instagram = "Instagram".localized()
        static let facebookLogin = "Facebook Login".localized()
        static let hashtags = "Hashtags".localized()
        static let quantityPerPack = "Quantity Per Pack".localized()
        static let saveAndShuffle = "Save & Shuffle".localized()
        static let keepPackOrder = "Keep Packs Order".localized()
        static let help = "Help".localized()
        static let onBoard = "On Board".localized()
        static let tricksAndTips = "Tricks & Tips".localized()
        static let instaSetup = "Instagram Setup".localized()
        static let aboutUs = "About us".localized()
        static let ourInstagram = "Our Instagram".localized()
        static let share = "Share".localized()
        static let rateAndReview = "Rate & Review".localized()
        static let contactUs = "Contact Us".localized()
        static let legal = "Legal".localized()
        static let privacy = "Privacy".localized()
        static let termsAndConditions = "Terms & Conditions".localized()
        static let disclaimer = "Disclaimer".localized()
    }

    /// Set by the view; the view model calls it to drive control-driven presentation.
    var onViewEvent: ((ViewEvent) -> Void)?

    /// The settings catalog the view renders. Built once, lazily, so the action
    /// closures can capture a fully-initialised view model.
    ///
    /// Intentionally not reactive: the only mutable rows are switches, which write
    /// straight through `onToggle`, and a fresh view model is built on every visit to
    /// Settings. Nothing on-screen can go stale, so there is no `onUpdate`/refresh loop.
    lazy var sections: [SettingsSectionModel] = buildSections()

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

    // MARK: - Catalog

    /// The full settings catalog: section order, titles, colors, and which action each row triggers.
    private func buildSections() -> [SettingsSectionModel] {
        let actions = makeActions()
        let settings = self.settings
        return [
            SettingsSectionModel(title: Strings.account, options: [
                .staticCell(model: SettingsOptionModel(
                    title: Strings.instagram,
                    iconBackgroundColor: .systemRed,
                    handler: actions.editInstagramUsername)),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.facebookLogin,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.openFacebookSetup)),
            ]),
            SettingsSectionModel(title: Strings.hashtags, options: [
                .staticCell(model: SettingsOptionModel(
                    title: Strings.quantityPerPack,
                    iconBackgroundColor: .systemPink,
                    handler: actions.showQuantityPicker)),
                .switchCell(model: SettingsSwitchOptionModel(
                    title: Strings.saveAndShuffle,
                    iconBackgroundColor: .systemYellow,
                    isOn: settings.saveAndShuffle,
                    onToggle: { settings.saveAndShuffle = $0 })),
                .switchCell(model: SettingsSwitchOptionModel(
                    title: Strings.keepPackOrder,
                    iconBackgroundColor: .systemRed,
                    isOn: settings.keepPacksOrder,
                    onToggle: { settings.keepPacksOrder = $0 })),
            ]),
            SettingsSectionModel(title: Strings.help, options: [
                .staticCell(model: SettingsOptionModel(
                    title: Strings.onBoard,
                    iconBackgroundColor: .systemTeal,
                    handler: actions.replayOnboarding)),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.tricksAndTips,
                    iconBackgroundColor: .systemBlue,
                    handler: { actions.openWebPage(Links.tricksAndTips) })),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.instaSetup,
                    iconBackgroundColor: .systemPurple,
                    handler: actions.openSetupInfo)),
            ]),
            SettingsSectionModel(title: Strings.aboutUs, options: [
                .staticCell(model: SettingsOptionModel(
                    title: Strings.ourInstagram,
                    iconBackgroundColor: .systemPink,
                    handler: actions.openOurInstagram)),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.share,
                    iconBackgroundColor: .systemGreen,
                    handler: actions.shareApp)),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.rateAndReview,
                    iconBackgroundColor: .systemYellow,
                    handler: actions.rateApp)),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.contactUs,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.contactSupport)),
            ]),
            SettingsSectionModel(title: Strings.legal, options: [
                .staticCell(model: SettingsOptionModel(
                    title: Strings.privacy,
                    iconBackgroundColor: .systemPurple,
                    handler: { actions.openWebPage(Links.privacyPolicy) })),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.termsAndConditions,
                    iconBackgroundColor: .systemYellow,
                    handler: { actions.openWebPage(Links.termsAndConditions) })),
                .staticCell(model: SettingsOptionModel(
                    title: Strings.disclaimer,
                    iconBackgroundColor: .systemRed,
                    handler: { actions.openWebPage(Links.disclaimer) })),
            ]),
        ]
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
