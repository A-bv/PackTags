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
        let viewModel = ThemeListViewModel(repository: dependencies.themeRepository, settings: dependencies.appSettings)
        let actions = ThemeListActions(
            selectTheme: { [weak self] theme in self?.showPackList(for: theme) },
            createTheme: { [weak self] in self?.showNewThemeEditor { viewModel.loadThemes() } },
            openSettings: { [weak self] in self?.showSettings() },
            openAnalytics: { [weak self] in self?.showAnalytics() },
            openSmartG: { [weak self] in self?.showSmartG() }
        )
        let vc = ThemeListViewController(style: .plain, viewModel: viewModel, actions: actions)
        vc.onViewDidAppear = { [weak self] in
            guard let self, viewModel.shouldShowOnboarding else { return }
            self.showOnboarding { [weak self] in
                guard let self, viewModel.consumeFirstTimeTipsAlert() else { return }
                Alerts.showFirstTimeTipsAlert(from: self.navigationController)
            }
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - From ThemeTableVC

    func showPackList(for theme: ThemeCD) {
        let vc = PackListViewController(
            style: .plain,
            viewModel: PackListViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings)
        )
        vc.onEditTheme = { [weak self, weak vc] pack in
            self?.showThemeEditor(
                for: theme,
                fromSwipe: pack != nil,
                chosenPack: pack ?? "",
                onSave: { vc?.editorDidSave() },
                onCancel: { vc?.editorDidClose() })
        }
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
        let navigation = SettingsNavigation(
            openQuantityPicker: { [weak self] in self?.showQuantityPicker() },
            replayOnboarding: { [weak self] in
                self?.dependencies.appSettings.hasSeenOnboarding = false
                self?.showOnboarding(completion: nil)
            }
        )
        let vc = SettingsVC(
            connectedInsights: dependencies.connectedInsights,
            appSettings: dependencies.appSettings,
            navigation: navigation
        )
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
        vc.onSave = { _ in
            onSave()
            ReviewPromptPolicy().promptIfEarned() // Review prompt only after updating an existing theme
        }
        vc.onCancel = onCancel
        if fromSwipe {
            vc.packToHighlight = chosenPack
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
