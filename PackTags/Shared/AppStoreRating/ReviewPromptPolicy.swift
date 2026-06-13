import UIKit
import StoreKit

protocol ReviewPromptStoreProtocol: AnyObject {
    var launchCount: Int { get }
    func incrementLaunchCount()
    var lastPromptedVersion: String? { get set }
    var lastPromptedBuild: String? { get set }
}

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

struct ReviewPromptPolicy {

    private enum Constants {
        static let minimumLaunches = 7
    }

    private let store: any ReviewPromptStoreProtocol
    private let presentReview: @MainActor () -> Bool

    init(
        store: any ReviewPromptStoreProtocol = ReviewPromptStore(),
        presentReview: @MainActor @escaping () -> Bool = ReviewPromptPolicy.presentStoreKitReview
    ) {
        self.store = store
        self.presentReview = presentReview
    }

    func registerLaunch() {
        store.incrementLaunchCount()
    }

    @MainActor
    func promptIfEarned() {
        guard
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String,
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            eligible(version: version, build: build)
        else { return }

        if presentReview() {
            markPrompted(version: version, build: build)
        }
    }

    private func eligible(version: String, build: String) -> Bool {
        guard store.launchCount > Constants.minimumLaunches else { return false }
        return version != store.lastPromptedVersion || build != store.lastPromptedBuild
    }

    private func markPrompted(version: String, build: String) {
        store.lastPromptedVersion = version
        store.lastPromptedBuild = build
    }

    @MainActor
    private static func presentStoreKitReview() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return false }
        AppStore.requestReview(in: scene)
        return true
    }
}
