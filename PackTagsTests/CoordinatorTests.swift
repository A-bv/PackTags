import Testing
import UIKit
import SwiftUI
import CoreData
@testable import PackTags

// MARK: - Test double

private final class SpyNavigationController: UINavigationController {
    private(set) var pushedVC: UIViewController?
    private(set) var presentedVC: UIViewController?
    private(set) var setRootVC: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedVC = viewController
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedVC = viewControllerToPresent
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setRootVC = viewControllers.first
    }
}

private final class SpyConnectedInsightsCoordinator: ConnectedInsightsCoordinating {
    private(set) var openedDestination: ConnectedInsightsDestination?
    private(set) var presenter: UIViewController?

    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        openedDestination = destination
        self.presenter = presenter
    }
}

private final class FakeAppSettings: AppSettingsProtocol {
    var tipsAlertShown = false
}

private final class FakeThemeRepository: ThemeRepositoryProtocol {
    private(set) var didSave = false

    func fetchAll() -> [ThemeCD] { [] }
    func create() -> ThemeCD { makeTheme() }
    func save() { didSave = true }
    func delete(_ theme: ThemeCD) {}
    func count() -> Int32 { 0 }
    func tagsAlreadyStored(tags: [String]) -> [String] { [] }
}

// MARK: - Helpers

private func makeTheme() -> ThemeCD {
    let desc = NSPersistentStoreDescription()
    desc.type = NSInMemoryStoreType
    let container = NSPersistentContainer(name: "PackTags")
    container.persistentStoreDescriptions = [desc]
    container.loadPersistentStores { _, _ in }
    return ThemeCD(context: container.viewContext)
}

@MainActor
private func makeDependencies(
    connectedInsights: ConnectedInsightsCoordinating? = nil
) -> AppDependencies {
    AppDependencies(
        themeRepository: FakeThemeRepository(),
        appSettings: FakeAppSettings(),
        connectedInsights: connectedInsights ?? SpyConnectedInsightsCoordinator()
    )
}

// MARK: - AppCoordinator

@Suite @MainActor struct AppCoordinatorTests {

    @Test func start_addsThemeCoordinatorAsOnlyChild() {
        let sut = AppCoordinator(window: UIWindow())
        sut.start()
        #expect(sut.childCoordinators.count == 1)
        #expect(sut.childCoordinators.first is ThemeCoordinator)
    }

    @Test func start_setsNavigationControllerAsWindowRootVC() {
        let window = UIWindow()
        let sut = AppCoordinator(window: window)
        sut.start()
        #expect(window.rootViewController === sut.navigationController)
    }
}

// MARK: - ThemeCoordinator

@Suite @MainActor struct ThemeCoordinatorTests {

    private func makeSUT() -> (ThemeCoordinator, SpyNavigationController) {
        let nav = SpyNavigationController()
        return (ThemeCoordinator(navigationController: nav, dependencies: makeDependencies()), nav)
    }

    // MARK: start

    @Test func start_setsThemeTableVCAsRoot() {
        let (sut, nav) = makeSUT()
        sut.start()
        #expect(nav.setRootVC is ThemeTableViewController)
    }

    @Test func start_assignsCoordinatorOnThemeTableVC() {
        let (sut, nav) = makeSUT()
        sut.start()
        let vc = nav.setRootVC as? ThemeTableViewController
        #expect(vc?.coordinator === sut)
    }

    // MARK: showPackList

    @Test func showPackList_pushesPackListViewController() {
        let (sut, nav) = makeSUT()
        sut.showPackList(for: makeTheme())
        #expect(nav.pushedVC is PackListViewController)
    }

    @Test func showPackList_assignsThemeAndCoordinator() {
        let (sut, nav) = makeSUT()
        let theme = makeTheme()
        sut.showPackList(for: theme)
        let vc = nav.pushedVC as? PackListViewController
        #expect(vc?.viewModel.theme === theme)
        #expect(vc?.coordinator === sut)
    }

    // MARK: showNewThemeEditor

    @Test func showNewThemeEditor_presentsThemeEditorViewControllerInsideNavController() {
        let (sut, nav) = makeSUT()
        sut.showNewThemeEditor(onSave: {})
        let nc = nav.presentedVC as? UINavigationController
        #expect(nc?.topViewController is ThemeEditorViewController)
    }

    @Test func showNewThemeEditor_themeVCHasNoThemeAndIsNew() {
        let (sut, nav) = makeSUT()
        sut.showNewThemeEditor(onSave: {})
        let themeVC = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(themeVC?.viewModel.theme == nil)
        #expect(themeVC?.viewModel.isNewTheme == true)
    }

    // MARK: showOnboarding

    @Test func showOnboarding_presentsOnBoardingController() {
        let (sut, nav) = makeSUT()
        sut.showOnboarding(completion: nil)
        #expect(nav.presentedVC is OnBoardingController)
    }

    @Test func showOnboarding_setsFullScreenPresentationStyle() {
        let (sut, nav) = makeSUT()
        sut.showOnboarding(completion: nil)
        #expect(nav.presentedVC?.modalPresentationStyle == .fullScreen)
    }

    @Test func showOnboarding_wiredCompletionIsPassedAsOnDismiss() {
        let (sut, nav) = makeSUT()
        var fired = false
        sut.showOnboarding(completion: { fired = true })
        let vc = nav.presentedVC as? OnBoardingController
        vc?.onDismiss?()
        #expect(fired)
    }

    // MARK: showSettings

    @Test func showSettings_pushesSettingsVC() {
        let (sut, nav) = makeSUT()
        sut.showSettings()
        #expect(nav.pushedVC is SettingsVC)
    }

    @Test func showSettings_assignsCoordinatorOnSettingsVC() {
        let (sut, nav) = makeSUT()
        sut.showSettings()
        let vc = nav.pushedVC as? SettingsVC
        #expect(vc?.coordinator === sut)
    }

    // MARK: showAnalytics

    @Test func showAnalytics_routesToConnectedInsights() {
        let nav = SpyNavigationController()
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let sut = ThemeCoordinator(
            navigationController: nav,
            dependencies: makeDependencies(connectedInsights: connectedInsights)
        )

        sut.showAnalytics()

        #expect(connectedInsights.openedDestination == .analytics)
        #expect(connectedInsights.presenter === nav)
    }

    // MARK: showSmartG

    @Test func showSmartG_routesToConnectedInsights() {
        let nav = SpyNavigationController()
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let sut = ThemeCoordinator(
            navigationController: nav,
            dependencies: makeDependencies(connectedInsights: connectedInsights)
        )

        sut.showSmartG()

        #expect(connectedInsights.openedDestination == .smartG)
        #expect(connectedInsights.presenter === nav)
    }

    // MARK: showThemeEditor

    @Test func showThemeEditor_presentsThemeEditorViewControllerInsideNavController() {
        let (sut, nav) = makeSUT()
        sut.showThemeEditor(for: makeTheme(), fromSwipe: false, chosenPack: "", onSave: {}, onCancel: {})
        let nc = nav.presentedVC as? UINavigationController
        #expect(nc?.topViewController is ThemeEditorViewController)
    }

    @Test func showThemeEditor_setsThemeAndMarksAsExisting() {
        let (sut, nav) = makeSUT()
        let theme = makeTheme()
        sut.showThemeEditor(for: theme, fromSwipe: false, chosenPack: "", onSave: {}, onCancel: {})
        let themeVC = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(themeVC?.viewModel.theme === theme)
        #expect(themeVC?.viewModel.isNewTheme == false)
    }

    @Test func showThemeEditor_fromSwipe_setsIsFromShowAndPack() {
        let (sut, nav) = makeSUT()
        sut.showThemeEditor(for: makeTheme(), fromSwipe: true, chosenPack: "#travel", onSave: {}, onCancel: {})
        let themeVC = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(themeVC?.isFromShow == true)
        #expect(themeVC?.packFromShow == "#travel")
    }

    @Test func showThemeEditor_notFromSwipe_isFromShowIsFalse() {
        let (sut, nav) = makeSUT()
        sut.showThemeEditor(for: makeTheme(), fromSwipe: false, chosenPack: "", onSave: {}, onCancel: {})
        let themeVC = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(themeVC?.isFromShow == false)
    }

    // MARK: childDidFinish

    @Test func childDidFinish_removesChildFromParent() {
        let nav = SpyNavigationController()
        let parent = AppCoordinator(window: UIWindow())
        let child = ThemeCoordinator(navigationController: nav, dependencies: makeDependencies())
        parent.childCoordinators.append(child)
        parent.childDidFinish(child)
        #expect(parent.childCoordinators.isEmpty)
    }
}
