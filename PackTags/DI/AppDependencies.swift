import Foundation

protocol AppSettingsProtocol {
    var isCorrectSetup: Bool { get set }
    var tipsAlertShown: Bool { get set }
}

protocol ConnectedInsightsSettingsProtocol: AppSettingsProtocol {
    var facebookToken: String? { get set }
    var instagramBusinessAccountId: String? { get set }
    var setupInfoShown: Bool { get set }
    var pressedFacebookLoginButton: Bool { get set }
}

final class UserDefaultsAppSettings: ConnectedInsightsSettingsProtocol {
    private enum Key {
        static let isCorrectSetup = "isCorrectSetup"
        static let tipsAlertShown = "showTipsAlertShown"
        static let facebookToken = "fbToken"
        static let instagramBusinessAccountId = "IgBId"
        static let setupInfoShown = "setupInfoShownOnce"
        static let pressedFacebookLoginButton = "pressedFBLoginButton"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isCorrectSetup: Bool {
        get { defaults.bool(forKey: Key.isCorrectSetup) }
        set { defaults.set(newValue, forKey: Key.isCorrectSetup) }
    }

    var tipsAlertShown: Bool {
        get { defaults.bool(forKey: Key.tipsAlertShown) }
        set { defaults.set(newValue, forKey: Key.tipsAlertShown) }
    }

    var facebookToken: String? {
        get { defaults.string(forKey: Key.facebookToken) }
        set { defaults.set(newValue, forKey: Key.facebookToken) }
    }

    var instagramBusinessAccountId: String? {
        get { defaults.string(forKey: Key.instagramBusinessAccountId) }
        set { defaults.set(newValue, forKey: Key.instagramBusinessAccountId) }
    }

    var setupInfoShown: Bool {
        get { defaults.bool(forKey: Key.setupInfoShown) }
        set { defaults.set(newValue, forKey: Key.setupInfoShown) }
    }

    var pressedFacebookLoginButton: Bool {
        get { defaults.bool(forKey: Key.pressedFacebookLoginButton) }
        set { defaults.set(newValue, forKey: Key.pressedFacebookLoginButton) }
    }
}

struct AppDependencies {
    let themeRepository: any ThemeRepositoryProtocol
    let appSettings: any ConnectedInsightsSettingsProtocol
    let instagramGraphService: any InstagramGraphServicing
    let connectedInsights: any ConnectedInsightsRouting
}
