import UIKit
import SwiftUI

@MainActor
final class NotebookCoordinator: CoordinatorProtocol {
    let navigationController: UINavigationController
    let dependencies: AppDependencies

    /// Child coordinators are retained while their flow is on screen.
    private var settingsCoordinator: SettingsCoordinator?
    private var onboardingCoordinator: OnboardingCoordinator?

    /// How the theme editor is built. Injectable so tests can verify the coordinator
    /// passes the right theme (nil = new) without reaching into the view model.
    private let makeThemeEditor: (ThemeEntity?) -> ThemeEditorViewController

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies,
        makeThemeEditor: ((ThemeEntity?) -> ThemeEditorViewController)? = nil
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.makeThemeEditor = makeThemeEditor ?? { theme in
            ThemeEditorViewController(viewModel: ThemeEditorViewModel(
                theme: theme,
                repository: dependencies.themeRepository,
                settings: dependencies.appSettings))
        }
    }

    func start() {
        showThemeList()
    }

    /// The navigation seam handed to the theme-list view model. Exposed so tests can
    /// invoke the callbacks directly and assert what the coordinator routes to.
    func makeThemeListNavigation() -> ThemeListNavigation {
        ThemeListNavigation(
            selectTheme: { [weak self] theme in self?.showPackList(for: theme) },
            createTheme: { [weak self] onCreated in self?.showNewThemeEditor(onSave: onCreated) },
            openSettings: { [weak self] in self?.showSettings() },
            openAnalytics: { [weak self] in self?.showAnalytics() },
            openSmartG: { [weak self] in self?.showSmartG() }
        )
    }

    private func showThemeList() {
        let navigation = makeThemeListNavigation()
        let viewModel = ThemeListViewModel(
            repository: dependencies.themeRepository,
            settings: dependencies.appSettings,
            navigation: navigation)

        let viewController = ThemeListViewController(style: .plain, viewModel: viewModel)
        viewController.onViewDidAppear = { [weak self, weak viewModel] in
            guard let self, let viewModel, viewModel.shouldShowOnboarding else { return }
            self.startOnboarding { [weak self, weak viewModel] in
                guard let self, let viewModel, viewModel.consumeFirstTimeTipsAlert() else { return }
                AlertPresenter.showFirstTimeTipsAlert(from: self.navigationController)
            }
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - From ThemeList

    private func showPackList(for theme: ThemeEntity) {
        let viewModel = PackListViewModel(theme: theme, repository: dependencies.themeRepository, settings: dependencies.appSettings)
        let viewController = PackListViewController(
            style: .plain,
            viewModel: viewModel)
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
        let viewController = makeThemeEditor(nil)
        viewController.onSave = { _ in onSave() }
        presentInNavController(viewController, transition: .coverVertical)
    }

    private func startOnboarding(onFinish: @escaping () -> Void) {
        let onboarding = OnboardingCoordinator(
            navigationController: navigationController,
            appSettings: dependencies.appSettings)
        onboarding.onFinish = { [weak self] in
            self?.onboardingCoordinator = nil
            onFinish()
        }
        onboardingCoordinator = onboarding
        onboarding.start()
    }

    private func showSettings() {
        let coordinator = SettingsCoordinator(
            navigationController: navigationController,
            dependencies: dependencies)
        settingsCoordinator = coordinator
        coordinator.start()
    }

    private func showAnalytics() {
        presentConnectedInsights(.analytics)
    }

    private func showSmartG() {
        presentConnectedInsights(.smartG)
    }

    // MARK: - From PackListViewController

    private func showThemeEditor(
        for theme: ThemeEntity,
        fromSwipe: Bool,
        chosenPack: String,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        let viewController = makeThemeEditor(theme)
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
