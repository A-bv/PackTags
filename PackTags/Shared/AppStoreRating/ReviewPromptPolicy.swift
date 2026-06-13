import UIKit
import StoreKit

/// Decides when to ask for an App Store review: only after enough launches,
/// and at most once per app version.
struct ReviewPromptPolicy {

    private enum Constants {
        static let minimumLaunches = 7
    }

    private let defaults: UserDefaults

    private var launchCount: Int {
        defaults.integer(forKey: SettingsKey.timesLaunched)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func registerLaunch() {
        defaults.set(launchCount + 1, forKey: SettingsKey.timesLaunched)
    }

    /// Shows the StoreKit review sheet when the policy allows it.
    @MainActor
    func promptIfEarned() {
        guard
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String,
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            eligible(
                version: version,
                build: build,
                promptedVersion: defaults.string(forKey: SettingsKey.lastVersionPromptedForReview),
                promptedBuild: defaults.string(forKey: SettingsKey.lastBuildPromptedForReview))
        else { return }

        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            markPrompted(version: version, build: build)
        }
    }

    private func eligible(version: String, build: String,
                          promptedVersion: String?, promptedBuild: String?) -> Bool {
        guard launchCount > Constants.minimumLaunches else { return false }
        return version != promptedVersion || build != promptedBuild
    }

    private func markPrompted(version: String, build: String) {
        defaults.set(version, forKey: SettingsKey.lastVersionPromptedForReview)
        defaults.set(build, forKey: SettingsKey.lastBuildPromptedForReview)
    }
}
