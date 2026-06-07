import Foundation

protocol ConnectedInsightsSettingsProtocol {
    var isCorrectSetup: Bool { get set }
    var facebookToken: String? { get set }
    var instagramBusinessAccountId: String? { get set }
    var setupInfoShown: Bool { get set }
    var pressedFacebookLoginButton: Bool { get set }
}

struct ConnectedInsightsConfiguration {
    var graphAPIVersion: String

    static let production = ConnectedInsightsConfiguration(graphAPIVersion: "v23.0")
}

final class UserDefaultsConnectedInsightsSettings: ConnectedInsightsSettingsProtocol {
    private enum Key {
        static let isCorrectSetup = "isCorrectSetup"
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
