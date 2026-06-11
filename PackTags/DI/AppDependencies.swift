import Foundation

protocol AppSettingsProtocol {
    var tipsAlertShown: Bool { get set }
}

final class UserDefaultsAppSettings: AppSettingsProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var tipsAlertShown: Bool {
        get { defaults.bool(forKey: SettingsKey.tipsAlertShown) }
        set { defaults.set(newValue, forKey: SettingsKey.tipsAlertShown) }
    }
}

struct AppDependencies {
    let persistence: PersistenceController
    let themeRepository: any ThemeRepositoryProtocol
    let appSettings: any AppSettingsProtocol
    let connectedInsights: any ConnectedInsightsCoordinating
}
