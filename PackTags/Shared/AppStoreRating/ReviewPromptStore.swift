import Foundation

final class ReviewPromptStore: ReviewPromptStoreProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var launchCount: Int {
        defaults.integer(forKey: SettingsKey.timesLaunched)
    }

    func incrementLaunchCount() {
        defaults.set(launchCount + 1, forKey: SettingsKey.timesLaunched)
    }

    var lastPromptedVersion: String? {
        get { defaults.string(forKey: SettingsKey.lastVersionPromptedForReview) }
        set { defaults.set(newValue, forKey: SettingsKey.lastVersionPromptedForReview) }
    }

    var lastPromptedBuild: String? {
        get { defaults.string(forKey: SettingsKey.lastBuildPromptedForReview) }
        set { defaults.set(newValue, forKey: SettingsKey.lastBuildPromptedForReview) }
    }
}
