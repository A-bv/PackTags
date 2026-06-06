import UIKit
import SwiftUI

final class ThemeCoordinator: Coordinator, ThemeCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ThemeTableViewController(style: .plain)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - From ThemeTableVC

    func showPackList(for theme: ThemeCD) {
        let vc = PackListViewController(style: .plain)
        vc.theme = theme
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showNewThemeEditor(onSave: @escaping () -> Void) {
        let vc = ThemeEditorViewController()
        vc.onSave = { _ in onSave() }
        presentInNavController(vc, transition: .coverVertical)
    }

    func showOnboarding(completion: (() -> Void)?) {
        let vc = OnBoardingController()
        vc.modalPresentationStyle = .fullScreen
        vc.onDismiss = completion
        navigationController.present(vc, animated: true)
    }

    func showSettings() {
        let vc = SettingsVC()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showAnalytics() {
        let vc = UIHostingController(rootView: AnalyticsNew())
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        navigationController.present(vc, animated: true)
    }

    func showSmartG() {
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        let vc: UIViewController = isCorrectSetup
            ? UIHostingController(rootView: SmartGViewContainer())
            : FBLoginVC(viewModel: FBLoginViewModel())
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        navigationController.present(vc, animated: true)
    }

    // MARK: - From PackListViewController

    func showThemeEditor(for theme: ThemeCD, fromSwipe: Bool, chosenPack: String, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let vc = ThemeEditorViewController()
        vc.theme = theme
        vc.isNotNewTheme = true
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
}
