import Foundation

protocol AppSettingsProtocol {
    var isCorrectSetup: Bool { get set }
    var tipsAlertShown: Bool { get set }
}

final class UserDefaultsAppSettings: AppSettingsProtocol {
    private enum Key {
        static let isCorrectSetup = "isCorrectSetup"
        static let tipsAlertShown = "showTipsAlertShown"
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
}

struct AppDependencies {
    let themeRepository: any ThemeRepositoryProtocol
    let appSettings: any AppSettingsProtocol
    let instagramGraphService: any InstagramGraphServicing
    let connectedInsights: any ConnectedInsightsRouting
}
