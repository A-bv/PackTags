import UIKit
import SwiftUI

@MainActor
final class ThemeCoordinator: Coordinator {
    let navigationController: UINavigationController
    let dependencies: AppDependencies

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        showThemeList()
    }

    private func showThemeList() {
        let actions = ThemeListActions(
            selectTheme: { [weak self] theme in self?.showPackList(for: theme) },
            createTheme: { [weak self] onCreated in self?.showNewThemeEditor(onSave: onCreated) },
            openSettings: { [weak self] in self?.showSettings() },
            openAnalytics: { [weak self] in self?.showAnalytics() },
            openSmartG: { [weak self] in self?.showSmartG() }
        )
        let viewModel = ThemeListViewModel(
            repository: dependencies.themeRepository,
            settings: dependencies.appSettings,
            actions: actions)

        let viewController = ThemeListViewController(style: .plain, viewModel: viewModel)
        viewController.onViewDidAppear = { [weak self, weak viewModel] in
            guard let self, let viewModel, viewModel.shouldShowOnboarding else { return }
            self.showOnboarding { [weak self, weak viewModel] in
                guard let self, let viewModel, viewModel.consumeFirstTimeTipsAlert() else { return }
                Alerts.showFirstTimeTipsAlert(from: self.navigationController)
            }
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - From ThemeList

    private func showPackList(for theme: ThemeCD) {
        let viewController = PackListViewController(
            style: .plain,
            viewModel: PackListViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings)
        )
        viewController.onEditTheme = { [weak self, weak viewController] pack in
            self?.showThemeEditor(
                for: theme,
                fromSwipe: pack != nil,
                chosenPack: pack ?? "",
                onSave: { viewController?.editorDidSave() },
                onCancel: { viewController?.editorDidClose() })
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showNewThemeEditor(onSave: @escaping () -> Void) {
        let viewController = ThemeEditorViewController(viewModel: ThemeEditorViewModel(theme: nil, repository: dependencies.themeRepository, settings: dependencies.appSettings))
        viewController.onSave = { _ in onSave() }
        presentInNavController(viewController, transition: .coverVertical)
    }

    private func showOnboarding(completion: (() -> Void)?) {
        let viewController = OnBoardingVC(appSettings: dependencies.appSettings)
        viewController.modalPresentationStyle = .fullScreen
        viewController.onDismiss = completion
        navigationController.present(viewController, animated: true)
    }

    private func showSettings() {
        let navigation = SettingsNavigation(
            openQuantityPicker: { [weak self] in self?.showQuantityPicker() },
            replayOnboarding: { [weak self] in
                self?.dependencies.appSettings.hasSeenOnboarding = false
                self?.showOnboarding(completion: nil)
            }
        )
        let viewController = SettingsVC(
            connectedInsights: dependencies.connectedInsights,
            appSettings: dependencies.appSettings,
            navigation: navigation
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showQuantityPicker() {
        let viewController = QuantityPickerVC(appSettings: dependencies.appSettings)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        navigationController.present(viewController, animated: true)
    }

    private func showAnalytics() {
        presentConnectedInsights(.analytics)
    }

    private func showSmartG() {
        presentConnectedInsights(.smartG)
    }

    // MARK: - From PackListViewController

    private func showThemeEditor(for theme: ThemeCD, fromSwipe: Bool, chosenPack: String, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let viewController = ThemeEditorViewController(viewModel: ThemeEditorViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings))
        viewController.onSave = { _ in
            onSave()
            ReviewPromptPolicy().promptIfEarned() // Review prompt only after updating an existing theme
        }
        viewController.onCancel = onCancel
        if fromSwipe {
            viewController.packToHighlight = chosenPack
        }
        presentInNavController(viewController, transition: .crossDissolve)
    }

    // MARK: - Private

    private func presentInNavController(_ viewController: ThemeEditorViewController, transition: UIModalTransitionStyle) {
        let nc = UINavigationController(rootViewController: viewController)
        nc.modalPresentationStyle = .overFullScreen
        nc.modalTransitionStyle = transition
        navigationController.present(nc, animated: true)
    }

    private func presentConnectedInsights(_ destination: ConnectedInsightsDestination) {
        dependencies.connectedInsights.open(destination, from: navigationController)
    }
}
