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
