import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let window: UIWindow
    private let dependencies: AppDependencies

    init(window: UIWindow) {
        self.window = window
        self.navigationController = ThemeNavigationController()
        let persistence = PersistenceController()
        self.dependencies = AppDependencies(
            persistence: persistence,
            themeRepository: CoreDataThemeRepository(context: persistence.viewContext),
            appSettings: UserDefaultsAppSettings(),
            connectedInsights: ConnectedInsightsCoordinator()
        )
    }

    func saveChanges() {
        dependencies.persistence.saveIfNeeded()
    }

    func start() {
        window.rootViewController = navigationController

        let coordinator = ThemeCoordinator(navigationController: navigationController, dependencies: dependencies)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
