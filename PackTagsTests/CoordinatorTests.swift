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

/// Records the theme the coordinator asks for (nil = new) and returns a real editor,
/// so construction can be verified without reaching into the editor's view model.
@MainActor
private final class SpyThemeEditorFactory {
    private(set) var capturedThemes: [ThemeEntity?] = []
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol

    init(repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.repository = repository
        self.settings = settings
    }

    func make(_ theme: ThemeEntity?) -> ThemeEditorViewController {
        capturedThemes.append(theme)
        return ThemeEditorViewController(viewModel: ThemeEditorViewModel(theme: theme, repository: repository, settings: settings))
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
    var pressedFacebookLoginButton = false
    var setupInfoShown = false
}

private final class FakeThemeRepository: ThemeRepositoryProtocol {
    private(set) var didSave = false
    private let persistence = PersistenceController(inMemory: true)
    var stored: [ThemeEntity] = []

    func fetchAll() -> [ThemeEntity] { stored }
    func create() -> ThemeEntity { ThemeEntity(context: persistence.viewContext) }
    func save() { didSave = true }
    func delete(_ theme: ThemeEntity) {}
    func count() -> Int32 { Int32(stored.count) }
    func tagsAlreadyStored(tags: [String]) -> [String] { [] }
}

// MARK: - Helpers

/// Kept alive for the whole suite: a theme whose context has deallocated
/// reads all its properties back as nil.
@MainActor
private let themeFactoryPersistence = PersistenceController(inMemory: true)

@MainActor
private func makeTheme(named name: String? = nil) -> ThemeEntity {
    let theme = ThemeEntity(context: themeFactoryPersistence.viewContext)
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
        themes: [ThemeEntity] = [],
        connectedInsights: ConnectedInsightsProtocol? = nil
    ) -> (sut: NotebookCoordinator, nav: SpyNavigationController, editorFactory: SpyThemeEditorFactory) {
        let nav = SpyNavigationController()
        let repository = FakeThemeRepository()
        repository.stored = themes
        let settings = FakeAppSettings()
        let dependencies = AppDependencies(
            persistence: PersistenceController(inMemory: true),
            themeRepository: repository,
            appSettings: settings,
            connectedInsights: connectedInsights ?? SpyConnectedInsightsCoordinator())
        let editorFactory = SpyThemeEditorFactory(repository: repository, settings: settings)
        let sut = NotebookCoordinator(
            navigationController: nav,
            dependencies: dependencies,
            makeThemeEditor: editorFactory.make)
        return (sut, nav, editorFactory)
    }

    private func startedRoot(_ sut: NotebookCoordinator, _ nav: SpyNavigationController) -> ThemeListViewController {
        sut.start()
        return nav.setRootVC as! ThemeListViewController
    }

    // MARK: start

    @Test func start_setsThemeTableVCAsRoot() {
        let (sut, nav, _) = makeSUT()
        sut.start()
        #expect(nav.setRootVC is ThemeListViewController)
    }

    @Test func start_wiresThemeListNavigation() {
        let (sut, nav, _) = makeSUT()
        sut.start()
        let vc = nav.setRootVC as? ThemeListViewController
        #expect(vc?.onViewDidAppear != nil)
    }

    // MARK: Routing (the coordinator's navigation callbacks → destinations)

    @Test func selectTheme_pushesPackListForThatTheme() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav, _) = makeSUT(themes: [theme])

        sut.makeThemeListNavigation().selectTheme(theme)

        let pushed = nav.pushedVC as? PackListViewController
        pushed?.loadViewIfNeeded()
        #expect(pushed?.title == "Travel")
        #expect(pushed?.onEditTheme != nil)
    }

    @Test func createTheme_presentsANewEditor() {
        let (sut, nav, editorFactory) = makeSUT()

        sut.makeThemeListNavigation().createTheme {}

        #expect(editorFactory.capturedThemes.count == 1)
        #expect(editorFactory.capturedThemes.first! == nil)
        #expect(nav.presentedVC is UINavigationController)
    }

    @Test func openSettings_pushesSettings() {
        let (sut, nav, _) = makeSUT()

        sut.makeThemeListNavigation().openSettings()

        #expect(nav.pushedVC is SettingsViewController)
    }

    @Test func openAnalytics_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav, _) = makeSUT(connectedInsights: connectedInsights)

        sut.makeThemeListNavigation().openAnalytics()

        #expect(connectedInsights.openedDestination == .analytics)
        #expect(connectedInsights.presenter === nav)
    }

    @Test func openSmartG_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav, _) = makeSUT(connectedInsights: connectedInsights)

        sut.makeThemeListNavigation().openSmartG()

        #expect(connectedInsights.openedDestination == .smartG)
        #expect(connectedInsights.presenter === nav)
    }

    // MARK: Editing a theme (from the pack list)

    @Test func editingTheme_presentsTheEditorForThatTheme() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav, editorFactory) = makeSUT(themes: [theme])
        sut.makeThemeListNavigation().selectTheme(theme)
        let packList = nav.pushedVC as? PackListViewController

        packList?.onEditTheme?(nil)

        #expect(editorFactory.capturedThemes.last! === theme)
        let editor = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(editor?.packToHighlight == nil)
    }

    @Test func editingPackFromSwipe_highlightsThatPack() {
        let theme = makeTheme(named: "Travel")
        let (sut, nav, _) = makeSUT(themes: [theme])
        sut.makeThemeListNavigation().selectTheme(theme)
        let packList = nav.pushedVC as? PackListViewController

        packList?.onEditTheme?("#travel")

        let editor = (nav.presentedVC as? UINavigationController)?.topViewController as? ThemeEditorViewController
        #expect(editor?.packToHighlight == "#travel")
    }

    // MARK: Onboarding (first appearance)

    @Test func firstAppearance_presentsOnboardingFullScreen() {
        let (sut, nav, _) = makeSUT()
        let root = startedRoot(sut, nav)

        root.onViewDidAppear?()

        #expect(nav.presentedVC is OnboardingViewController)
        #expect(nav.presentedVC?.modalPresentationStyle == .fullScreen)
    }

    @Test func dismissingOnboarding_presentsTheFirstTimeTipsAlert() {
        let (sut, nav, _) = makeSUT()
        let root = startedRoot(sut, nav)
        root.onViewDidAppear?()
        let onboarding = nav.presentedVC as? OnboardingViewController

        onboarding?.onDismiss?()

        #expect(nav.presentedVC is UIAlertController)
    }
}

// MARK: - SettingsCoordinator

@Suite @MainActor struct SettingsCoordinatorTests {

    private func makeSUT(
        connectedInsights: ConnectedInsightsProtocol? = nil
    ) -> (sut: SettingsCoordinator, nav: SpyNavigationController) {
        let nav = SpyNavigationController()
        let dependencies = AppDependencies(
            persistence: PersistenceController(inMemory: true),
            themeRepository: FakeThemeRepository(),
            appSettings: FakeAppSettings(),
            connectedInsights: connectedInsights ?? SpyConnectedInsightsCoordinator())
        return (SettingsCoordinator(navigationController: nav, dependencies: dependencies), nav)
    }

    @Test func start_pushesSettings() {
        let (sut, nav) = makeSUT()
        sut.start()
        #expect(nav.pushedVC is SettingsViewController)
    }

    @Test func quantityPicker_isPresented() {
        let (sut, nav) = makeSUT()
        sut.makeSettingsNavigation().openQuantityPicker()
        #expect(nav.presentedVC is QuantityPickerViewController)
    }

    @Test func facebookSetup_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav) = makeSUT(connectedInsights: connectedInsights)
        sut.makeSettingsNavigation().openFacebookSetup()
        #expect(connectedInsights.openedDestination == .setup)
        #expect(connectedInsights.presenter === nav)
    }

    @Test func setupInfo_routesToConnectedInsights() {
        let connectedInsights = SpyConnectedInsightsCoordinator()
        let (sut, nav) = makeSUT(connectedInsights: connectedInsights)
        sut.makeSettingsNavigation().openSetupInfo()
        #expect(connectedInsights.openedDestination == .setupInfo)
        #expect(connectedInsights.presenter === nav)
    }
}
