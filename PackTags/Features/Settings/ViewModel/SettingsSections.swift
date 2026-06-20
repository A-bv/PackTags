import UIKit

/// The full settings catalog: section order, titles, colors, and which action
/// each row triggers.
enum SettingsSections {
    private enum Strings {
        static let account = "Account".localized()
        // Row label. Coincidentally equal to the alert title in SettingsViewController,
        // but a different role — kept separate so renaming one never silently moves the other.
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

    private enum Links {
        static let tricksAndTips = "https://sites.google.com/view/packtags-tricks-tips/accueil"
        static let privacyPolicy = "https://sites.google.com/view/packtags-privacy-policy/accueil"
        static let termsAndConditions = "https://sites.google.com/view/packtagstc/accueil"
        static let disclaimer = "https://sites.google.com/view/packtagsdisclaimer/accueil"
    }

    static func make(actions: SettingsActions, settings: any AppSettingsProtocol) -> [SettingsSection] {
        return [
            SettingsSection(title: Strings.account, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.instagram,
                    iconBackgroundColor: .systemRed,
                    handler: actions.editInstagramUsername)),
                .staticCell(model: SettingsOption(
                    title: Strings.facebookLogin,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.openFacebookSetup)),
            ]),
            SettingsSection(title: Strings.hashtags, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.quantityPerPack,
                    iconBackgroundColor: .systemPink,
                    handler: actions.showQuantityPicker)),
                .switchCell(model: SettingsSwitchOption(
                    title: Strings.saveAndShuffle,
                    iconBackgroundColor: .systemYellow,
                    isOn: settings.saveAndShuffle,
                    onToggle: { settings.saveAndShuffle = $0 })),
                .switchCell(model: SettingsSwitchOption(
                    title: Strings.keepPackOrder,
                    iconBackgroundColor: .systemRed,
                    isOn: settings.keepPacksOrder,
                    onToggle: { settings.keepPacksOrder = $0 })),
            ]),
            SettingsSection(title: Strings.help, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.onBoard,
                    iconBackgroundColor: .systemTeal,
                    handler: actions.replayOnboarding)),
                .staticCell(model: SettingsOption(
                    title: Strings.tricksAndTips,
                    iconBackgroundColor: .systemBlue,
                    handler: { actions.openWebPage(Links.tricksAndTips) })),
                .staticCell(model: SettingsOption(
                    title: Strings.instaSetup,
                    iconBackgroundColor: .systemPurple,
                    handler: actions.openSetupInfo)),
            ]),
            SettingsSection(title: Strings.aboutUs, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.ourInstagram,
                    iconBackgroundColor: .systemPink,
                    handler: actions.openOurInstagram)),
                .staticCell(model: SettingsOption(
                    title: Strings.share,
                    iconBackgroundColor: .systemGreen,
                    handler: actions.shareApp)),
                .staticCell(model: SettingsOption(
                    title: Strings.rateAndReview,
                    iconBackgroundColor: .systemYellow,
                    handler: actions.rateApp)),
                .staticCell(model: SettingsOption(
                    title: Strings.contactUs,
                    iconBackgroundColor: .systemOrange,
                    handler: actions.contactSupport)),
            ]),
            SettingsSection(title: Strings.legal, options: [
                .staticCell(model: SettingsOption(
                    title: Strings.privacy,
                    iconBackgroundColor: .systemPurple,
                    handler: { actions.openWebPage(Links.privacyPolicy) })),
                .staticCell(model: SettingsOption(
                    title: Strings.termsAndConditions,
                    iconBackgroundColor: .systemYellow,
                    handler: { actions.openWebPage(Links.termsAndConditions) })),
                .staticCell(model: SettingsOption(
                    title: Strings.disclaimer,
                    iconBackgroundColor: .systemRed,
                    handler: { actions.openWebPage(Links.disclaimer) })),
            ]),
        ]
    }
}
