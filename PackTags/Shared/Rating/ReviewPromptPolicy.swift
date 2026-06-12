import UIKit
import StoreKit

/// Decides when to ask for an App Store review: only after enough launches,
/// and at most once per app version.
struct ReviewPromptPolicy {
    private enum Constants {
        static let minimumLaunches = 7
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func registerLaunch() {
        defaults.set(launchCount + 1, forKey: SettingsKey.timesLaunched)
    }

    var launchCount: Int {
        defaults.integer(forKey: SettingsKey.timesLaunched)
    }

    func shouldPrompt(version: String, build: String) -> Bool {
        let promptedVersion = defaults.string(forKey: SettingsKey.lastVersionPromptedForReview)
        let promptedBuild = defaults.string(forKey: SettingsKey.lastBuildPromptedForReview)
        guard version != promptedVersion || build != promptedBuild else { return false }
        return launchCount > Constants.minimumLaunches
    }

    func markPrompted(version: String, build: String) {
        defaults.set(version, forKey: SettingsKey.lastVersionPromptedForReview)
        defaults.set(build, forKey: SettingsKey.lastBuildPromptedForReview)
    }

    /// Shows the StoreKit review sheet when the policy allows it.
    func promptIfEarned() {
        guard
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String,
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            shouldPrompt(version: version, build: build)
        else { return }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        markPrompted(version: version, build: build)
    }
}
