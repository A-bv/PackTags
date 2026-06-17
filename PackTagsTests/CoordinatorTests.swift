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

private final class SpyConnectedInsightsCoordinator: ConnectedInsightsProtocol {
    private(set) var openedDestination: ConnectedInsightsDestination?
    private(set) var presenter: UIViewController?

    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        openedDestination = destination
        self.presenter = presenter
    }
}

private final class FakeAppSettings: AppSettingsProtocol {
    var hasSeenOnboarding = false
    var tipsAlertShown = false
    var tagsPerPack = 30
    var saveAndShuffle = false
    var keepPacksOrder = false
    var openInstagramAfterCopy = false
    var instagramUsername: String?
    var pressedFBLoginButton = false
    var setupInfoShown = false
}

private final class FakeThemeRepository: ThemeRepositoryProtocol {
    private(set) var didSave = false
    private let persistence = PersistenceController(inMemory: true)
    var stored: [ThemeCD] = []

    func fetchAll() -> [ThemeCD] { stored }
    func create() -> ThemeCD { ThemeCD(context: persistence.viewContext) }
    func save() { didSave = true }
    func delete(_ theme: ThemeCD) {}
    func count() -> Int32 { Int32(stored.count) }
    func tagsAlreadyStored(tags: [String]) -> [String] { [] }
}

// MARK: - Helpers

/// Kept alive for the whole suite: a theme whose context has deallocated
/// reads all its properties back as nil.
@MainActor
private let themeFactoryPersistence = PersistenceController(inMemory: true)

@MainActor
private func makeTheme(named name: String? = nil) -> ThemeCD {
    let theme = ThemeCD(context: themeFactoryPersistence.viewContext)
    theme.name = name
    return theme
}

// MARK: - AppCoordinator

@Suite @MainActor struct AppCoordinatorTests {

    @Test func start_setsThemeListAsRootAndWiresItsNavigation() {
        let sut = AppCoordinator(window: UIWindow())
        sut.start()
        let root = sut.navigationController.viewControllers.first as? ThemeListViewController
        #expect(root != nil)
        #expect(root?.onViewDidAppear != nil)
    }

    @Test func start_setsNavigationControllerAsWindowRootVC() {
        let window = UIWindow()
        let sut = AppCoordinator(window: window)
        sut.start()
        #expect(window.rootViewController === sut.navigationController)
    }
}

// MARK: - NotebookCoordinator

@Suite @MainActor struct NotebookCoordinatorTests {

    private func makeSUT(
        themes: [ThemeCD] = [],
        connectedInsights: ConnectedInsightsProtocol? = nil
    ) -> (sut: NotebookCoordinator, nav: SpyNavigationController) {
        let nav = SpyNavigationController()
        let repository = FakeThemeRepository()
        repository.stored = themes
        let dependencies = AppDependencies(
            persistence: PersistenceController(inMemory: true),
            themeRepository: repository,
            appSettings: FakeAppSettings(),
            connectedInsights: connectedInsights ?? SpyConnectedInsightsCoordinator())
        return (NotebookCoordinator(navigationController: nav, dependencies: dependencies), nav)
    }

    /// Starts the coordinator and returns the live theme-list root with its
    /// themes loaded, so tests can drive navigation through its view model.
    private func startedRoot(_ sut: NotebookCoordinator, _ nav: SpyNavigationController) -> ThemeListViewController {
        sut.start()
        let root = nav.setRootVC as! ThemeListViewController
        root.viewModel.loadThemes()
        return root
    }

    // MARK: start

    @Test func start_setsThemeTableVCAsRoot() {
        let (sut, nav) = makeSUT()
        sut.start()
        #expect(nav.setRootVC is ThemeListViewController)
    }

    @Test func start_wiresThemeListNavigation() {
        let (sut, nav) = makeSUT()
        sut.start()
        let vc = nav.setRootVC as? ThemeListViewController
        #expect(vc?.onViewDidAppear != nil)
    }

    // MARK: Notebook navigation (driven through the view model's callbacks)

    @Test func selectingTheme_pushesPackListForThatTheme() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav) = makeSUT(themes: [theme])
        let root = startedRoot(sut, nav)

        root.viewModel.selectTheme(at: 0)

        let pushed = nav.pushedVC as? PackListViewController
        #expect(pushed?.viewModel.title == "Travel")
        #expect(pushed?.onEditTheme != nil)
    }

    @Test func creatingTheme_presentsANewThemeEditor() {
        let (sut, nav) = makeSUT()
        let root = startedRoot(sut, nav)

        root.viewModel.createTheme()

        let editor = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(editor?.viewModel.theme == nil)
        #expect(editor?.viewModel.isNewTheme == true)
    }

    @Test func openingSettings_pushesSettings() {
        let (sut, nav) = makeSUT()
        let root = startedRoot(sut, nav)

        root.viewModel.openSettings()

        #expect(nav.pushedVC is SettingsViewController)
    }

    @Test func openingAnalytics_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav) = makeSUT(connectedInsights: connectedInsights)
        let root = startedRoot(sut, nav)

        root.viewModel.openAnalytics()

        #expect(connectedInsights.openedDestination == .analytics)
        #expect(connectedInsights.presenter === nav)
    }

    @Test func openingSmartG_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav) = makeSUT(connectedInsights: connectedInsights)
        let root = startedRoot(sut, nav)

        root.viewModel.openSmartG()

        #expect(connectedInsights.openedDestination == .smartG)
        #expect(connectedInsights.presenter === nav)
    }

    // MARK: Editing a theme (from the pack list)

    @Test func editingTheme_presentsTheEditorForThatThemeAsExisting() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav) = makeSUT(themes: [theme])
        let root = startedRoot(sut, nav)
        root.viewModel.selectTheme(at: 0)
        let packList = nav.pushedVC as? PackListViewController

        packList?.onEditTheme?(nil)

        let editor = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(editor?.viewModel.theme === theme)
        #expect(editor?.viewModel.isNewTheme == false)
        #expect(editor?.packToHighlight == nil)
    }

    @Test func editingPackFromSwipe_highlightsThatPack() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav) = makeSUT(themes: [theme])
        let root = startedRoot(sut, nav)
        root.viewModel.selectTheme(at: 0)
        let packList = nav.pushedVC as? PackListViewController

        packList?.onEditTheme?("#travel")

        let editor = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(editor?.packToHighlight == "#travel")
    }

    // MARK: Onboarding (first appearance)

    @Test func firstAppearance_presentsOnboardingFullScreen() {
        let (sut, nav) = makeSUT()
        let root = startedRoot(sut, nav)

        root.onViewDidAppear?()

        #expect(nav.presentedVC is OnboardingViewController)
        #expect(nav.presentedVC?.modalPresentationStyle == .fullScreen)
    }

    @Test func dismissingOnboarding_presentsTheFirstTimeTipsAlert() {
        let (sut, nav) = makeSUT()
        let root = startedRoot(sut, nav)
        root.onViewDidAppear?()
        let onboarding = nav.presentedVC as? OnboardingViewController

        onboarding?.onDismiss?()

        #expect(nav.presentedVC is UIAlertController)
    }

    // MARK: Settings → quantity picker

    @Test func settingsQuantityPickerAction_presentsQuantityPicker() {
        let (sut, nav) = makeSUT()
        let root = startedRoot(sut, nav)
        root.viewModel.openSettings()
        let settings = nav.pushedVC as? SettingsViewController

        guard case .staticCell(let quantityRow) = settings?.viewModel.sections[1].options[0] else {
            Issue.record("expected the quantity-per-pack row")
            return
        }
        quantityRow.handler()

        #expect(nav.presentedVC is QuantityPickerViewController)
    }

}
