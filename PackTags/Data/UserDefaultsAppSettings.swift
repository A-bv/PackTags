import Foundation

protocol AppSettingsProtocol: AnyObject {
    var hasSeenOnboarding: Bool { get set }
    var tipsAlertShown: Bool { get set }
    var tagsPerPack: Int { get set }
    var saveAndShuffle: Bool { get set }
    var keepPacksOrder: Bool { get set }
    var openInstagramAfterCopy: Bool { get set }
    var instagramUsername: String? { get set }
    var pressedFBLoginButton: Bool { get set }
    var setupInfoShown: Bool { get set }
}

final class UserDefaultsAppSettings: AppSettingsProtocol {
    private enum Default {
        static let tagsPerPack = 30
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: SettingsKey.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: SettingsKey.hasSeenOnboarding) }
    }

    var tipsAlertShown: Bool {
        get { defaults.bool(forKey: SettingsKey.tipsAlertShown) }
        set { defaults.set(newValue, forKey: SettingsKey.tipsAlertShown) }
    }

    var pressedFBLoginButton: Bool {
        get { defaults.bool(forKey: SettingsKey.pressedFBLoginButton) }
        set { defaults.set(newValue, forKey: SettingsKey.pressedFBLoginButton) }
    }

    var setupInfoShown: Bool {
        get { defaults.bool(forKey: SettingsKey.setupInfoShown) }
        set { defaults.set(newValue, forKey: SettingsKey.setupInfoShown) }
    }

    var tagsPerPack: Int {
        get {
            let saved = defaults.integer(forKey: SettingsKey.quantityOfTagsPerPack)
            return saved == 0 ? Default.tagsPerPack : saved
        }
        set { defaults.set(newValue, forKey: SettingsKey.quantityOfTagsPerPack) }
    }

    var saveAndShuffle: Bool {
        get { defaults.bool(forKey: SettingsKey.saveAndShuffle) }
        set { defaults.set(newValue, forKey: SettingsKey.saveAndShuffle) }
    }

    var keepPacksOrder: Bool {
        get { defaults.bool(forKey: SettingsKey.keepPacksOrder) }
        set { defaults.set(newValue, forKey: SettingsKey.keepPacksOrder) }
    }

    var openInstagramAfterCopy: Bool {
        get { defaults.bool(forKey: SettingsKey.openInstagramAfterCopy) }
        set { defaults.set(newValue, forKey: SettingsKey.openInstagramAfterCopy) }
    }

    var instagramUsername: String? {
        get { defaults.string(forKey: SettingsKey.instagramUsername) }
        set { defaults.set(newValue, forKey: SettingsKey.instagramUsername) }
    }
}
