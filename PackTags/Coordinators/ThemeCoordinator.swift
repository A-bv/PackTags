import UIKit
import SwiftUI

@MainActor
final class ThemeCoordinator: Coordinator, ThemeCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    let dependencies: AppDependencies

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = ThemeTableViewController(
            style: .plain,
            appSettings: dependencies.appSettings,
            viewModel: ThemeListViewModel(repository: dependencies.themeRepository)
        )
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - From ThemeTableVC

    func showPackList(for theme: ThemeCD) {
        let vc = PackListViewController(
            style: .plain,
            viewModel: PackListViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings)
        )
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showNewThemeEditor(onSave: @escaping () -> Void) {
        let vc = ThemeEditorViewController(viewModel: ThemeEditorViewModel(theme: nil, repository: dependencies.themeRepository, settings: dependencies.appSettings))
        vc.onSave = { _ in onSave() }
        presentInNavController(vc, transition: .coverVertical)
    }

    func showOnboarding(completion: (() -> Void)?) {
        let vc = OnBoardingController()
        vc.appSettings = dependencies.appSettings
        vc.modalPresentationStyle = .fullScreen
        vc.onDismiss = completion
        navigationController.present(vc, animated: true)
    }

    func showSettings() {
        let vc = SettingsVC(connectedInsights: dependencies.connectedInsights, appSettings: dependencies.appSettings)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showQuantityPicker() {
        let vc = QuantityPickerVC(appSettings: dependencies.appSettings)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
    }

    func showAnalytics() {
        presentConnectedInsights(.analytics)
    }

    func showSmartG() {
        presentConnectedInsights(.smartG)
    }

    // MARK: - From PackListViewController

    func showThemeEditor(for theme: ThemeCD, fromSwipe: Bool, chosenPack: String, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let vc = ThemeEditorViewController(viewModel: ThemeEditorViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings))
        vc.onSave = { _ in onSave() }
        vc.onCancel = onCancel
        if fromSwipe {
            vc.isFromShow = true
            vc.packFromShow = chosenPack
        }
        presentInNavController(vc, transition: .crossDissolve)
    }

    // MARK: - Private

    private func presentInNavController(_ vc: ThemeEditorViewController, transition: UIModalTransitionStyle) {
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .overFullScreen
        nc.modalTransitionStyle = transition
        navigationController.present(nc, animated: true)
    }

    private func presentConnectedInsights(_ destination: ConnectedInsightsDestination) {
        dependencies.connectedInsights.open(destination, from: navigationController)
    }
}
