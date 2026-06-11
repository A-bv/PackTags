import Testing
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

    private func makeSUT() -> (viewModel: ThemeListViewModel, repository: CoreDataThemeRepository) {
        let persistence = PersistenceController(inMemory: true)
        let repository = CoreDataThemeRepository(context: persistence.viewContext)
        return (ThemeListViewModel(repository: repository), repository)
    }

    private func seedThemes(_ names: [String], in repository: CoreDataThemeRepository) {
        for (index, name) in names.enumerated() {
            let theme = repository.create()
            theme.name = name
            theme.orderIndex = Int32(index)
        }
        repository.save()
    }

    @Test func loadThemes_populatesThemesAndNotifies() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B"], in: repository)

        var didNotify = false
        sut.onUpdate = { didNotify = true }
        sut.loadThemes()

        #expect(didNotify)
        #expect(sut.themes.compactMap(\.name) == ["A", "B"])
    }

    @Test func reorderTheme_persistsTheNewOrder() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B", "C"], in: repository)
        sut.loadThemes()

        sut.reorderTheme(from: 0, to: 2)

        #expect(sut.themes.compactMap(\.name) == ["B", "C", "A"])
        #expect(repository.fetchAll().compactMap(\.name) == ["B", "C", "A"])
    }

    @Test func deleteTheme_removesItFromRepository() {
        let (sut, repository) = makeSUT()
        seedThemes(["A", "B"], in: repository)
        sut.loadThemes()

        sut.deleteTheme(at: 0)

        #expect(sut.themes.compactMap(\.name) == ["B"])
        #expect(repository.count() == 1)
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

    @Test func postCopyAction_respectsKeepPacksOrderAndRedirectSettings() {
        let (sut, settings) = makeSUT()
        settings.keepPacksOrder = true
        settings.openInstagramAfterCopy = true
        settings.instagramUsername = "packtags"

        let action = sut.postCopyAction()

        #expect(action.shouldMovePackToBottom == false)
        #expect(action.instagramUsername == "packtags")
    }

    @Test func postCopyAction_withRedirectOff_hasNoUsername() {
        let (sut, settings) = makeSUT()
        settings.openInstagramAfterCopy = false

        #expect(sut.postCopyAction().instagramUsername == nil)
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
        #expect(SettingsKey.pressedFBLoginButton == "pressedFBLoginButton")
        #expect(SettingsKey.lastStatsRefresh == "LastStatsRefresh")
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
