import Testing
import UIKit
import CoreData
@testable import PackTags

// MARK: - CoreDataThemeRepository

@Suite struct ThemeRepositoryTests {

    private func makeSUT() -> CoreDataThemeRepository {
        let persistence = PersistenceController(inMemory: true)
        return CoreDataThemeRepository(context: persistence.viewContext)
    }

    @Test func inMemoryStore_loadsWithoutError() {
        let persistence = PersistenceController(inMemory: true)
        #expect(persistence.loadError == nil)
    }

    @Test func destroyStore_wipesPersistedData() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PackTagsDestroyTest-\(UUID().uuidString).sqlite")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        // Seed a theme into a real on-disk store.
        let persistence = PersistenceController(storeURL: url)
        #expect(persistence.loadError == nil)
        let repo = CoreDataThemeRepository(context: persistence.viewContext)
        repo.create().name = "Doomed"
        repo.save()
        #expect(repo.count() == 1)

        persistence.destroyStore()

        // Reopening the same location must yield a fresh, empty store.
        let reopened = PersistenceController(storeURL: url)
        #expect(CoreDataThemeRepository(context: reopened.viewContext).count() == 0)
    }

    @Test func create_thenSave_isReturnedByFetchAll() {
        let sut = makeSUT()

        let theme = sut.create()
        theme.name = "Travel"
        theme.content = "#travel #sunset"
        sut.save()

        let fetched = sut.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Travel")
    }

    @Test func fetchAll_sortsByOrderIndex() {
        let sut = makeSUT()

        let second = sut.create()
        second.name = "B"
        second.orderIndex = 1
        let first = sut.create()
        first.name = "A"
        first.orderIndex = 0
        sut.save()

        #expect(sut.fetchAll().compactMap(\.name) == ["A", "B"])
    }

    @Test func delete_removesThemeFromStore() {
        let sut = makeSUT()
        let theme = sut.create()
        theme.name = "Doomed"
        sut.save()

        sut.delete(theme)

        #expect(sut.fetchAll().isEmpty)
        #expect(sut.count() == 0)
    }

    @Test func count_reflectsNumberOfStoredThemes() {
        let sut = makeSUT()
        #expect(sut.count() == 0)

        sut.create().name = "One"
        sut.create().name = "Two"
        sut.save()

        #expect(sut.count() == 2)
    }

    @Test func tagsAlreadyStored_returnsOnlyTagsPresentInThemeContent() {
        let sut = makeSUT()
        let theme = sut.create()
        theme.content = "#sunset #beach"
        sut.save()

        let matched = sut.tagsAlreadyStored(tags: ["#sunset", "#mountain"])

        #expect(matched == ["#sunset"])
    }

    @Test func tagsAlreadyStored_withEmptyInput_returnsEmpty() {
        let sut = makeSUT()
        #expect(sut.tagsAlreadyStored(tags: []).isEmpty)
    }
}

// MARK: - ThemeListViewModel

@Suite struct ThemeListViewModelTests {

    private final class FakeSettings: AppSettingsProtocol {
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

    private func noopNavigation(
        selectTheme: @escaping (ThemeEntity) -> Void = { _ in },
        createTheme: @escaping (@escaping () -> Void) -> Void = { _ in },
        openSettings: @escaping () -> Void = {},
        openAnalytics: @escaping () -> Void = {},
        openSmartG: @escaping () -> Void = {}
    ) -> ThemeListNavigation {
        ThemeListNavigation(
            selectTheme: selectTheme,
            createTheme: createTheme,
            openSettings: openSettings,
            openAnalytics: openAnalytics,
            openSmartG: openSmartG)
    }

    private func makeSUT(navigation: ThemeListNavigation? = nil) -> (viewModel: ThemeListViewModel, repository: CoreDataThemeRepository) {
        let persistence = PersistenceController(inMemory: true)
        let repository = CoreDataThemeRepository(context: persistence.viewContext)
        return (ThemeListViewModel(repository: repository, settings: FakeSettings(), navigation: navigation ?? noopNavigation()), repository)
    }

    private func makeSUTWithSettings() -> (ThemeListViewModel, FakeSettings) {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let settings = FakeSettings()
        return (ThemeListViewModel(repository: repository, settings: settings, navigation: noopNavigation()), settings)
    }

    private func names(_ sut: ThemeListViewModel) -> [String?] {
        (0..<sut.themeCount).map { sut.themeRow(at: $0)?.name }
    }

    private func seedThemes(_ names: [String], in repository: CoreDataThemeRepository) {
        for (index, name) in names.enumerated() {
            let theme = repository.create()
            theme.name = name
            theme.orderIndex = Int32(index)
        }
        repository.save()
    }

    @Test func shouldShowOnboarding_followsTheSettingsFlag() {
        let (sut, settings) = makeSUTWithSettings()
        #expect(sut.shouldShowOnboarding)

        settings.hasSeenOnboarding = true
        #expect(!sut.shouldShowOnboarding)
    }

    @Test func consumeFirstTimeTipsAlert_returnsTrueExactlyOnce() {
        let (sut, settings) = makeSUTWithSettings()

        #expect(sut.consumeFirstTimeTipsAlert())
        #expect(settings.tipsAlertShown)
        #expect(!sut.consumeFirstTimeTipsAlert())
    }

    @Test func loadThemes_populatesRowsAndNotifies() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B"], in: repository)

        var didNotify = false
        sut.onUpdate = { didNotify = true }
        sut.loadThemes()

        #expect(didNotify)
        #expect(names(sut) == ["A", "B"])
    }

    @Test func themeRow_exposesNameAndIsNilForStaleIndex() {
        let (sut, repository) = makeSUT()
        seedThemes(["A"], in: repository)
        sut.loadThemes()

        #expect(sut.themeRow(at: 0)?.name == "A")
        #expect(sut.themeRow(at: 9) == nil)
    }

    @Test func selectTheme_atValidIndex_firesActionWithThatTheme() {
        var selected: ThemeEntity?
        let (sut, repository) = makeSUT(navigation: noopNavigation(selectTheme: { selected = $0 }))
        seedThemes(["A", "B"], in: repository)
        sut.loadThemes()

        sut.selectTheme(at: 1)

        #expect(selected?.name == "B")
    }

    @Test func selectTheme_atInvalidIndex_doesNotFire() {
        var fired = false
        let (sut, _) = makeSUT(navigation: noopNavigation(selectTheme: { _ in fired = true }))

        sut.selectTheme(at: 0)

        #expect(!fired)
    }

    @Test func createTheme_firesNavigation() {
        var fired = false
        let (sut, _) = makeSUT(navigation: noopNavigation(createTheme: { _ in fired = true }))

        sut.createTheme()

        #expect(fired)
    }

    @Test func openSettings_firesNavigation() {
        var fired = false
        let (sut, _) = makeSUT(navigation: noopNavigation(openSettings: { fired = true }))

        sut.openSettings()

        #expect(fired)
    }

    @Test func openAnalytics_firesNavigation() {
        var fired = false
        let (sut, _) = makeSUT(navigation: noopNavigation(openAnalytics: { fired = true }))

        sut.openAnalytics()

        #expect(fired)
    }

    @Test func openSmartG_firesNavigation() {
        var fired = false
        let (sut, _) = makeSUT(navigation: noopNavigation(openSmartG: { fired = true }))

        sut.openSmartG()

        #expect(fired)
    }

    @Test func reorderTheme_persistsTheNewOrder() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B", "C"], in: repository)
        sut.loadThemes()

        sut.reorderTheme(from: 0, to: 2)

        #expect(names(sut) == ["B", "C", "A"])
        #expect(repository.fetchAll().compactMap(\.name) == ["B", "C", "A"])
    }

    @Test func deleteTheme_removesItFromRepository() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B"], in: repository)
        sut.loadThemes()

        sut.deleteTheme(at: 0)

        #expect(names(sut) == ["B"])
        #expect(repository.count() == 1)
    }

    @Test func deleteTheme_withInvalidIndex_doesNothing() {
        let (sut, _) = makeSUT()
        sut.deleteTheme(at: 5)
        #expect(sut.themeCount == 0)
    }
}

// MARK: - PackListViewModel

@Suite struct PackListViewModelTests {

    private final class FakeSettings: AppSettingsProtocol {
        var hasSeenOnboarding = false
        var tipsAlertShown = false
        var tagsPerPack = 2
        var saveAndShuffle = false
        var keepPacksOrder = false
        var openInstagramAfterCopy = false
        var instagramUsername: String?
        var pressedFacebookLoginButton = false
        var setupInfoShown = false
    }

    private func makeSUT(content: String? = "#a #b #c") -> (PackListViewModel, FakeSettings) {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let theme = repository.create()
        theme.content = content
        repository.save()
        let settings = FakeSettings()
        return (PackListViewModel(theme: theme, repository: repository, settings: settings), settings)
    }

    @Test func loadPacks_chunksContentByTagsPerPack() {
        let (sut, _) = makeSUT()
        sut.loadPacks()
        #expect(sut.packs == ["#a #b", "#c"])
    }

    @Test func packRow_exposesFirstTagAndBadgePerPack() {
        let (sut, _) = makeSUT()
        sut.loadPacks()

        #expect(sut.packRow(at: 0)?.firstTag == "#a")
        #expect(sut.packRow(at: 0)?.badge == " + 1 \("more".localized()) ")
        #expect(sut.packRow(at: 1)?.firstTag == "#c")
        #expect(sut.packRow(at: 1)?.badge == " \("1 Hashtag".localized()) ")
    }

    @Test func packRow_withStaleIndex_isNil() {
        let (sut, _) = makeSUT()
        sut.loadPacks()
        #expect(sut.packRow(at: 9) == nil)
    }

    @Test func packDetail_returnsThePackContents() {
        let (sut, _) = makeSUT()
        sut.loadPacks()
        #expect(sut.packDetail(at: 0) == "#a #b")
        #expect(sut.packDetail(at: 1) == "#c")
    }

    @Test func packDetail_whenThePackIsEmpty_returnsTheHint() {
        let (sut, _) = makeSUT(content: "")
        sut.loadPacks()
        #expect(sut.packDetail(at: 0) == "Tap the Pencil button to add Hashtags.".localized())
    }

    @Test func postCopyAction_respectsKeepPacksOrderAndRedirectSettings() {
        let (sut, settings) = makeSUT()
        settings.keepPacksOrder = true
        settings.openInstagramAfterCopy = true
        settings.instagramUsername = "packtags"

        let action = sut.postCopyAction()

        #expect(action.shouldMovePackToBottom == false)
        #expect(action.instagramAppURL == "instagram://user?username=packtags")
        #expect(action.instagramWebURL == "https://instagram.com/packtags")
    }

    @Test func postCopyAction_withRedirectOff_hasNoLinks() {
        let (sut, settings) = makeSUT()
        settings.openInstagramAfterCopy = false

        #expect(sut.postCopyAction().instagramAppURL == nil)
        #expect(sut.postCopyAction().shouldMovePackToBottom == true)
    }

    @Test func toggleInstagramRedirect_withoutUsername_promptsForIt() {
        let (sut, _) = makeSUT()
        guard case .promptForUsername = sut.toggleInstagramRedirect() else {
            Issue.record("expected promptForUsername")
            return
        }
    }

    @Test func toggleInstagramRedirect_flipsTheSettingBothWays() {
        let (sut, settings) = makeSUT()
        settings.instagramUsername = "packtags"

        guard case .enabled(let enabledName) = sut.toggleInstagramRedirect() else {
            Issue.record("expected enabled")
            return
        }
        #expect(enabledName == "packtags")
        #expect(settings.openInstagramAfterCopy)

        guard case .disabled = sut.toggleInstagramRedirect() else {
            Issue.record("expected disabled")
            return
        }
        #expect(!settings.openInstagramAfterCopy)
    }

    @Test func saveInstagramUsername_trimsAndEnablesRedirect() {
        let (sut, settings) = makeSUT()

        let saved = sut.saveInstagramUsername("  packtags \n")

        #expect(saved == "packtags")
        #expect(settings.instagramUsername == "packtags")
        #expect(settings.openInstagramAfterCopy)
    }
}

// MARK: - SettingsKey contract

/// These raw values are the app's on-disk contract: shipped devices already
/// store data under these exact strings. Renaming one orphans user data —
/// most dangerously hasSeenOnboarding, whose loss would re-trigger first-run
/// seeding in AppDelegate and overwrite the user's database with samples.
@Suite struct SettingsKeyContractTests {

    @Test func rawValues_matchTheShippedOnDiskContract() {
        #expect(SettingsKey.hasSeenOnboarding == "isNewUser")
        #expect(SettingsKey.tipsAlertShown == "showTipsAlertShown")
        #expect(SettingsKey.instagramUsername == "Instagram Username")
        #expect(SettingsKey.openInstagramAfterCopy == "goInsta")
        #expect(SettingsKey.keepPacksOrder == "Keep Packs Order")
        #expect(SettingsKey.saveAndShuffle == "Save & Shuffle")
        #expect(SettingsKey.setupInfoShown == "setupInfoShown")
        #expect(SettingsKey.pressedFacebookLoginButton == "pressedFBLoginButton")
        #expect(SettingsKey.quantityOfTagsPerPack == "QuantityOfTagsPerPack")
        #expect(SettingsKey.timesLaunched == "numberOfTimesLaunched")
        #expect(SettingsKey.lastVersionPromptedForReview == "lastVersion")
        #expect(SettingsKey.lastBuildPromptedForReview == "lastBuild")
    }

    @Test func seedTrigger_onlyFiresWhenOnboardingWasNeverSeen() {
        let defaults = UserDefaults(suiteName: "SettingsKeyContractTests")!
        defaults.removePersistentDomain(forName: "SettingsKeyContractTests")
        let settings = UserDefaultsAppSettings(defaults: defaults)

        #expect(settings.hasSeenOnboarding == false)

        defaults.set(true, forKey: "isNewUser")
        #expect(settings.hasSeenOnboarding == true)
    }
}

// MARK: - Settings catalog (built by SettingsViewModel)

@Suite @MainActor struct SettingsCatalogTests {

    private final class FakeSettings: AppSettingsProtocol {
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

    private func makeSUT() -> SettingsViewModel {
        SettingsViewModel(
            settings: FakeSettings(),
            navigation: SettingsNavigation(
                openQuantityPicker: {},
                replayOnboarding: {},
                openFacebookSetup: {},
                openSetupInfo: {}))
    }

    @Test func catalog_hasFiveSections() {
        #expect(makeSUT().sections.count == 5)
    }

    @Test func firstAccountRow_emitsEditInstagram() {
        let sut = makeSUT()
        var event: SettingsViewModel.ViewEvent?
        sut.onViewEvent = { event = $0 }

        guard case .staticCell(let option) = sut.sections[0].options[0] else {
            Issue.record("expected a static cell")
            return
        }
        option.handler()

        guard case .editInstagram = event else {
            Issue.record("expected an editInstagram event")
            return
        }
    }

    @Test func legalSection_opensAWebPagePerRow() {
        let sut = makeSUT()
        var openedCount = 0
        sut.onViewEvent = { if case .openWebPage = $0 { openedCount += 1 } }

        for option in sut.sections[4].options {
            if case .staticCell(let model) = option { model.handler() }
        }

        #expect(openedCount == 3)
    }
}

// MARK: - SettingsViewModel

@Suite @MainActor struct SettingsViewModelTests {

    private final class FakeSettings: AppSettingsProtocol {
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

    private func navigation(openQuantityPicker: @escaping () -> Void = {}) -> SettingsNavigation {
        SettingsNavigation(
            openQuantityPicker: openQuantityPicker,
            replayOnboarding: {},
            openFacebookSetup: {},
            openSetupInfo: {})
    }

    private func staticHandler(_ vm: SettingsViewModel, section: Int, row: Int) -> (() -> Void)? {
        guard case .staticCell(let model) = vm.sections[section].options[row] else { return nil }
        return model.handler
    }

    @Test func quantityRow_routesThroughNavigation() {
        var fired = false
        let vm = SettingsViewModel(settings: FakeSettings(), navigation: navigation(openQuantityPicker: { fired = true }))

        staticHandler(vm, section: 1, row: 0)?()

        #expect(fired)
    }

    @Test func shareRow_emitsShareAppEvent() {
        let vm = SettingsViewModel(settings: FakeSettings(), navigation: navigation())
        var event: SettingsViewModel.ViewEvent?
        vm.onViewEvent = { event = $0 }

        staticHandler(vm, section: 3, row: 1)?()

        if case .shareApp = event {} else {
            Issue.record("expected a shareApp event, got \(String(describing: event))")
        }
    }

    @Test func saveInstagramUsername_trimsWhitespace() {
        let settings = FakeSettings()
        let vm = SettingsViewModel(settings: settings, navigation: navigation())

        vm.saveInstagramUsername("  packtags  ")

        #expect(settings.instagramUsername == "packtags")
    }
}

// MARK: - ThemeEditorViewModel

@Suite struct ThemeEditorViewModelTests {

    private final class FakeSettings: AppSettingsProtocol {
        var hasSeenOnboarding = false
        var tipsAlertShown = false
        var tagsPerPack = 2
        var saveAndShuffle = false
        var keepPacksOrder = false
        var openInstagramAfterCopy = false
        var instagramUsername: String?
        var pressedFacebookLoginButton = false
        var setupInfoShown = false
    }

    private func makeSUT(theme: ThemeEntity? = nil) -> ThemeEditorViewModel {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        return ThemeEditorViewModel(theme: theme, repository: repository, settings: FakeSettings())
    }

    @Test func canSave_requiresATitle() {
        let sut = makeSUT()
        #expect(!sut.canSave)

        sut.themeTitle = "Travel"
        #expect(sut.canSave)
    }

    @Test func save_createsANewThemeWithSanitizedContent() {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let sut = ThemeEditorViewModel(theme: nil, repository: repository, settings: FakeSettings())
        sut.themeTitle = "Travel"

        sut.save(rawText: "#sea #sea and some #sun", imageData: nil, thumbnailData: nil)

        #expect(repository.count() == 1)
        #expect(sut.theme?.name == "Travel")
        #expect(sut.theme?.content == "#sea #sun")
    }

    @Test func nameAlert_withoutATitle_promptsForAName() {
        let sut = makeSUT()

        let alert = sut.nameAlert

        #expect(alert.title == "New Theme".localized())
        #expect(alert.message.isEmpty)
        #expect(alert.placeholder == "Enter Name".localized())
    }

    @Test func nameAlert_withATitle_promptsForARename() {
        let sut = makeSUT()
        sut.themeTitle = "Travel"

        let alert = sut.nameAlert

        #expect(alert.title == "Travel")
        #expect(alert.message == "Edit Name".localized())
        #expect(alert.placeholder == "Enter New Name".localized())
    }

    @Test func contentByPrepending_intoAnEmptyEditor_isTheRecognizedTextAlone() {
        #expect(makeSUT().contentByPrepending(recognizedText: "#sun", to: "") == "#sun")
    }

    @Test func contentByPrepending_ontoExistingText_separatesWithABlankLine() {
        #expect(makeSUT().contentByPrepending(recognizedText: "#sun", to: "#sea") == "#sun\n\n#sea")
    }

    @Test func save_updatesAnExistingTheme_withoutCreatingANewOne() {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let existing = repository.create()
        existing.name = "Old"
        existing.content = "#old"
        repository.save()

        let sut = ThemeEditorViewModel(theme: existing, repository: repository, settings: FakeSettings())
        sut.themeTitle = "Updated"
        sut.save(rawText: "#new #new", imageData: nil, thumbnailData: nil)

        #expect(repository.count() == 1)            // updated in place, not duplicated
        #expect(sut.theme?.name == "Updated")
        #expect(sut.theme?.content == "#new")
    }

    @Test func save_storesImageAndThumbnailData() {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let sut = ThemeEditorViewModel(theme: nil, repository: repository, settings: FakeSettings())
        sut.themeTitle = "Travel"
        let image = Data([0x01, 0x02])
        let thumbnail = Data([0x03])

        sut.save(rawText: "#sea", imageData: image, thumbnailData: thumbnail)

        #expect(sut.theme?.image == image)
        #expect(sut.theme?.thumbnail == thumbnail)
    }

    @Test func shuffleContent_dedupesAndPreservesTheTagSet() {
        let sut = makeSUT()

        let result = sut.shuffleContent(rawText: "#sea #sea #sun")

        let tags = Set(result.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init))
        #expect(tags == ["#sea", "#sun"])   // shuffle order varies; the set must not
    }

    @Test func contentForDisplay_withNoTheme_isNil() {
        #expect(makeSUT().contentForDisplay() == nil)
    }

    @Test func contentForDisplay_groupsTheContentIntoPacks() {
        let repository = CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
        let theme = repository.create()
        theme.content = "#a #b #c #d"
        repository.save()
        let settings = FakeSettings()
        settings.tagsPerPack = 2
        let sut = ThemeEditorViewModel(theme: theme, repository: repository, settings: settings)

        #expect(sut.contentForDisplay() == "#a #b\n\n#c #d")
    }
}

