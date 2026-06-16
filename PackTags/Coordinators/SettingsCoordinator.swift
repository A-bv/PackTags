import UIKit

/// Owns the Settings flow: the screen itself plus everything it can navigate to
/// (quantity picker, onboarding replay, Facebook setup). Started as a child of
/// NotebookCoordinator so that coordinator no longer knows Settings' internals.
@MainActor
final class SettingsCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let dependencies: AppDependencies
    private var onboardingCoordinator: OnboardingCoordinator?

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let navigation = SettingsNavigation(
            openQuantityPicker: { [weak self] in self?.showQuantityPicker() },
            replayOnboarding: { [weak self] in self?.replayOnboarding() },
            openFacebookSetup: { [weak self] in self?.presentConnectedInsights(.setup) },
            openSetupInfo: { [weak self] in self?.presentConnectedInsights(.setupInfo) }
        )
        let viewModel = SettingsViewModel(settings: dependencies.appSettings, navigation: navigation)
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showQuantityPicker() {
        let viewController = QuantityPickerViewController(appSettings: dependencies.appSettings)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        navigationController.present(viewController, animated: true)
    }

    private func replayOnboarding() {
        dependencies.appSettings.hasSeenOnboarding = false
        let onboarding = OnboardingCoordinator(
            navigationController: navigationController,
            appSettings: dependencies.appSettings)
        onboarding.onFinish = { [weak self] in self?.onboardingCoordinator = nil }
        onboardingCoordinator = onboarding
        onboarding.start()
    }

    private func presentConnectedInsights(_ destination: ConnectedInsightsDestination) {
        dependencies.connectedInsights.open(destination, from: navigationController)
    }
}
