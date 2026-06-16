import UIKit

/// Presents the onboarding flow. Shared by first launch (NotebookCoordinator) and the
/// "replay onboarding" action in Settings, so the presentation lives in one place.
@MainActor
final class OnboardingCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let appSettings: any AppSettingsProtocol

    /// Called once onboarding is dismissed.
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController, appSettings: any AppSettingsProtocol) {
        self.navigationController = navigationController
        self.appSettings = appSettings
    }

    func start() {
        let viewController = OnBoardingVC(appSettings: appSettings)
        viewController.modalPresentationStyle = .fullScreen
        viewController.onDismiss = { [weak self] in self?.onFinish?() }
        navigationController.present(viewController, animated: true)
    }
}
