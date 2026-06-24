import Foundation

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

    var pressedFacebookLoginButton: Bool {
        get { defaults.bool(forKey: SettingsKey.pressedFacebookLoginButton) }
        set { defaults.set(newValue, forKey: SettingsKey.pressedFacebookLoginButton) }
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
