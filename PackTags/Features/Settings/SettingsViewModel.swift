import Foundation

final class SettingsViewModel {
    /// The settings catalog the view renders. Built once from the injected
    /// actions (presentation triggers) and the current settings.
    let sections: [SettingsSection]

    private let settings: any AppSettingsProtocol

    init(actions: SettingsActions, settings: any AppSettingsProtocol) {
        self.settings = settings
        self.sections = SettingsSections.make(actions: actions, settings: settings)
    }

    var instagramUsername: String {
        settings.instagramUsername ?? ""
    }

    func saveInstagramUsername(_ rawName: String) {
        settings.instagramUsername = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
