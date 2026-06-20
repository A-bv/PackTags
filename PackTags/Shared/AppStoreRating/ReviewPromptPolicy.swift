import UIKit
import StoreKit

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
