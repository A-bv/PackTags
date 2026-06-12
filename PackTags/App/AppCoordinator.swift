import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    /// View controllers hold their coordinator weakly; this reference keeps
    /// the notebook flow's coordinator alive for the app's lifetime.
    private var themeCoordinator: ThemeCoordinator?
    let navigationController: UINavigationController
    private let window: UIWindow
    private let dependencies: AppDependencies

    init(window: UIWindow) {
        self.window = window
        self.navigationController = ThemeNavigationController()
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

        let coordinator = ThemeCoordinator(navigationController: navigationController, dependencies: dependencies)
        themeCoordinator = coordinator
        coordinator.start()
    }
}
