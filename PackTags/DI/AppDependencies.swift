import Foundation

protocol AppSettingsProtocol {
    var tipsAlertShown: Bool { get set }
}

final class UserDefaultsAppSettings: AppSettingsProtocol {
    private enum Key {
        static let tipsAlertShown = "showTipsAlertShown"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var tipsAlertShown: Bool {
        get { defaults.bool(forKey: Key.tipsAlertShown) }
        set { defaults.set(newValue, forKey: Key.tipsAlertShown) }
    }
}

struct AppDependencies {
    let persistence: PersistenceController
    let themeRepository: any ThemeRepositoryProtocol
    let appSettings: any AppSettingsProtocol
    let connectedInsights: any ConnectedInsightsCoordinating
}
