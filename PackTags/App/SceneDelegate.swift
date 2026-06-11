import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    //Fb login
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }

        let handled = ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: context.url,
            sourceApplication: context.options.sourceApplication,
            annotation: context.options.annotation
        )
        AppLogger.login.info("Facebook openURL handled: \(handled, privacy: .public)")
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let coordinator = AppCoordinator(window: window)
        appCoordinator = coordinator
        coordinator.start()
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        appCoordinator?.saveChanges()
    }
}
