import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let window: UIWindow
    private let dependencies: AppDependencies

    init(window: UIWindow) {
        self.window = window
        self.navigationController = ThemeNavigationController()
        self.dependencies = AppDependencies(themeRepository: CoreDataThemeRepository())
    }

    func start() {
        window.rootViewController = navigationController

        let coordinator = ThemeCoordinator(navigationController: navigationController, dependencies: dependencies)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
