import CoreData

final class ThemeListViewModel {
    struct ThemeRow {
        let id: NSManagedObjectID
        let name: String?
        let thumbnail: Data?
    }

    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    private let navigation: ThemeListNavigation
    private var themes: [ThemeCD] = []
    var onUpdate: (() -> Void)?

    init(repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol, navigation: ThemeListNavigation) {
        self.repository = repository
        self.settings = settings
        self.navigation = navigation
    }

    // MARK: - Presentation

    var themeCount: Int { themes.count }

    /// Row data for the cell at `index`; nil when the index is stale.
    func themeRow(at index: Int) -> ThemeRow? {
        guard themes.indices.contains(index) else { return nil }
        let theme = themes[index]
        return ThemeRow(id: theme.objectID, name: theme.name, thumbnail: theme.thumbnail)
    }

    // MARK: - Navigation intents

    func selectTheme(at index: Int) {
        guard themes.indices.contains(index) else { return }
        navigation.selectTheme(themes[index])
    }

    func createTheme() { navigation.createTheme { [weak self] in self?.loadThemes() } }
    func openSettings() { navigation.openSettings() }
    func openAnalytics() { navigation.openAnalytics() }
    func openSmartG() { navigation.openSmartG() }

    // MARK: - Onboarding

    var shouldShowOnboarding: Bool {
        !settings.hasSeenOnboarding
    }

    /// Call once onboarding finishes; true exactly once per install.
    func consumeFirstTimeTipsAlert() -> Bool {
        guard !settings.tipsAlertShown else { return false }
        settings.tipsAlertShown = true
        return true
    }

    // MARK: - Data

    func loadThemes() {
        themes = repository.fetchAll()
        onUpdate?()
    }

    func reorderTheme(from sourceIndex: Int, to destinationIndex: Int) {
        guard themes.indices.contains(sourceIndex), themes.indices.contains(destinationIndex) else { return }
        let moved = themes.remove(at: sourceIndex)
        themes.insert(moved, at: destinationIndex)
        for (i, theme) in themes.enumerated() {
            theme.orderIndex = Int32(i)
        }
        repository.save()
    }

    func deleteTheme(at index: Int) {
        guard themes.indices.contains(index) else { return }
        repository.delete(themes.remove(at: index))
    }
}
