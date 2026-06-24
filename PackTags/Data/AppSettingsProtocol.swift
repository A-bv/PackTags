import Foundation

protocol AppSettingsProtocol: AnyObject {
    var hasSeenOnboarding: Bool { get set }
    var tipsAlertShown: Bool { get set }
    var tagsPerPack: Int { get set }
    var saveAndShuffle: Bool { get set }
    var keepPacksOrder: Bool { get set }
    var openInstagramAfterCopy: Bool { get set }
    var instagramUsername: String? { get set }
    var pressedFacebookLoginButton: Bool { get set }
    var setupInfoShown: Bool { get set }
}
