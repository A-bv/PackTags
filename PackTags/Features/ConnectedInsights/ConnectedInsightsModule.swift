import SwiftUI
import UIKit

enum ConnectedInsightsDestination {
    case analytics
    case smartG
    case setup
    case setupInfo
}

protocol ConnectedInsightsRouting {
    func makeViewController(for destination: ConnectedInsightsDestination) -> UIViewController
}

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

final class ConnectedInsightsModule: ConnectedInsightsRouting {
    private let settings: any ConnectedInsightsSettingsProtocol
    private let instagramGraphService: any InstagramGraphServicing

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        configuration: ConnectedInsightsConfiguration = .production,
        instagramGraphService: (any InstagramGraphServicing)? = nil
    ) {
        self.settings = settings
        self.instagramGraphService = instagramGraphService ?? InstagramGraphService(
            settings: settings,
            apiGraphVersion: configuration.graphAPIVersion
        )
    }

    func makeViewController(for destination: ConnectedInsightsDestination) -> UIViewController {
        switch destination {
        case .analytics:
            guard settings.isCorrectSetup else {
                return FBLoginVC(settings: settings)
            }
            return UIHostingController(
                rootView: AnalyticsNew(instagramGraphService: instagramGraphService))
        case .smartG:
            guard settings.isCorrectSetup else {
                return FBLoginVC(settings: settings)
            }
            return UIHostingController(
                rootView: SmartGViewContainer(instagramGraphService: instagramGraphService))
        case .setup:
            return FBLoginVC(settings: settings)
        case .setupInfo:
            return InfoSetupIGCreatorVC(settings: settings)
        }
    }
}
