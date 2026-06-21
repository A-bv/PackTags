import Foundation

/// Every UserDefaults key the app reads or writes. Raw values are historical
/// and must not change — shipped devices already store data under these names.
enum SettingsKey {
    static let hasSeenOnboarding = "isNewUser"
    static let tipsAlertShown = "showTipsAlertShown"
    static let instagramUsername = "Instagram Username"
    static let openInstagramAfterCopy = "goInsta"
    static let keepPacksOrder = "Keep Packs Order"
    static let saveAndShuffle = "Save & Shuffle"
    static let setupInfoShown = "setupInfoShown"
    static let pressedFacebookLoginButton = "pressedFBLoginButton"
    static let quantityOfTagsPerPack = "QuantityOfTagsPerPack"
    static let timesLaunched = "numberOfTimesLaunched"
    static let lastVersionPromptedForReview = "lastVersion"
    static let lastBuildPromptedForReview = "lastBuild"
}
