import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

struct SettingsSwitchOption {
    let title: String
    let storageKey: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
    var isOn: Bool
}

/// Behaviors the settings list can trigger. The view controller supplies the
/// implementations; the catalog below stays free of view and navigation code.
struct SettingsActions {
    let editInstagramUsername: () -> Void
    let openFacebookSetup: () -> Void
    let showQuantityPicker: () -> Void
    let replayOnboarding: () -> Void
    let openSetupInfo: () -> Void
    let openWebPage: (String) -> Void
    let openOurInstagram: () -> Void
    let shareApp: () -> Void
    let rateApp: () -> Void
    let contactSupport: () -> Void
}

/// The full settings catalog: section order, titles, colors, and which action
/// each row triggers.
enum SettingsSections {
    private enum Strings {
        static let account = "Account".localized()
        static let instagram = "Instagram".localized()
        static let facebookLogin = "Facebook Login".localized()
        static let hashtags = "Hastags".localized()
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

    private enum Links {
        static let tricksAndTips = "https://sites.google.com/view/packtags-tricks-tips/accueil"
        static let privacyPolicy = "https://sites.google.com/view/packtags-privacy-policy/accueil"
        static let termsAndConditions = "https://sites.google.com/view/packtagstc/accueil"
        static let disclaimer = "https://sites.google.com/view/packtagsdisclaimer/accueil"
    }

    static func make(actions: SettingsActions) -> [SettingsSection] {
        let icon = UIImage(systemName: "gearshape")!

        return [
            SettingsSection(title: Strings.account, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.instagram,
                    icon: icon,
                    iconBackgroundColor: .systemRed,
                    handler: actions.editInstagramUsername)),
                .staticCell(model: SettingsOption(
                    title: Strings.facebookLogin,
                    icon: icon,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.openFacebookSetup)),
            ]),
            SettingsSection(title: Strings.hashtags, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.quantityPerPack,
                    icon: icon,
                    iconBackgroundColor: .systemPink,
                    handler: actions.showQuantityPicker)),
                .switchCell(model: SettingsSwitchOption(
                    title: Strings.saveAndShuffle,
                    storageKey: SettingsKey.saveAndShuffle,
                    icon: icon,
                    iconBackgroundColor: .systemYellow,
                    handler: {}, isOn: false)),
                .switchCell(model: SettingsSwitchOption(
                    title: Strings.keepPackOrder,
                    storageKey: SettingsKey.keepPacksOrder,
                    icon: icon,
                    iconBackgroundColor: .systemRed,
                    handler: {}, isOn: false)),
            ]),
            SettingsSection(title: Strings.help, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.onBoard,
                    icon: icon,
                    iconBackgroundColor: .systemTeal,
                    handler: actions.replayOnboarding)),
                .staticCell(model: SettingsOption(
                    title: Strings.tricksAndTips,
                    icon: icon,
                    iconBackgroundColor: .systemBlue,
                    handler: { actions.openWebPage(Links.tricksAndTips) })),
                .staticCell(model: SettingsOption(
                    title: Strings.instaSetup,
                    icon: icon,
                    iconBackgroundColor: .systemPurple,
                    handler: actions.openSetupInfo)),
            ]),
            SettingsSection(title: Strings.aboutUs, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.ourInstagram,
                    icon: icon,
                    iconBackgroundColor: .systemPink,
                    handler: actions.openOurInstagram)),
                .staticCell(model: SettingsOption(
                    title: Strings.share,
                    icon: icon,
                    iconBackgroundColor: .systemGreen,
                    handler: actions.shareApp)),
                .staticCell(model: SettingsOption(
                    title: Strings.rateAndReview,
                    icon: icon,
                    iconBackgroundColor: .systemYellow,
                    handler: actions.rateApp)),
                .staticCell(model: SettingsOption(
                    title: Strings.contactUs,
                    icon: icon,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.contactSupport)),
            ]),
            SettingsSection(title: Strings.legal, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.privacy,
                    icon: icon,
                    iconBackgroundColor: .systemPurple,
                    handler: { actions.openWebPage(Links.privacyPolicy) })),
                .staticCell(model: SettingsOption(
                    title: Strings.termsAndConditions,
                    icon: icon,
                    iconBackgroundColor: .systemYellow,
                    handler: { actions.openWebPage(Links.termsAndConditions) })),
                .staticCell(model: SettingsOption(
                    title: Strings.disclaimer,
                    icon: icon,
                    iconBackgroundColor: .systemRed,
                    handler: { actions.openWebPage(Links.disclaimer) })),
            ]),
        ]
    }
}
