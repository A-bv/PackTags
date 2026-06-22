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
    }
}
