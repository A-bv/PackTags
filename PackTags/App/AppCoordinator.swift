import UIKit

@MainActor
final class AppCoordinator: CoordinatorProtocol {
    /// View controllers hold their coordinator weakly; this reference keeps
    /// the notebook flow's coordinator alive for the app's lifetime.
    private var notebookCoordinator: NotebookCoordinator?
    let navigationController: UINavigationController
    private let window: UIWindow
    private let dependencies: AppDependencies

    init(window: UIWindow) {
        self.window = window
        self.navigationController = StatusBarForwardingNavigationController()
        let persistence = PersistenceController()
        let appSettings = UserDefaultsAppSettings()
        self.dependencies = AppDependencies(
            persistence: persistence,
            themeRepository: CoreDataThemeRepository(context: persistence.viewContext),
            appSettings: appSettings,
            connectedInsights: ConnectedInsightsCoordinator(settings: appSettings)
        )
    }

    func saveChanges() {
        dependencies.persistence.saveIfNeeded()
    }

    func start() {
        window.rootViewController = navigationController

        let coordinator = NotebookCoordinator(navigationController: navigationController, dependencies: dependencies)
        notebookCoordinator = coordinator
        coordinator.start()

        if dependencies.persistence.loadError != nil {
            presentStoreLoadError()
        }
    }

    /// Surfaces a store-load failure once the window is live (the scene makes it key after
    /// `start()` returns, so presenting must wait for the next run loop).
    private func presentStoreLoadError() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            AlertPresenter.showStoreLoadError(from: self.navigationController) { [weak self] in
                guard let self else { return }
                self.dependencies.persistence.destroyStore()
                AlertPresenter.showStoreResetConfirmation(from: self.navigationController)
            }
        }
    }
}
