import Foundation

final class ThemeListViewModel {
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    private(set) var themes: [ThemeCD] = []
    var onUpdate: (() -> Void)?

    init(repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.repository = repository
        self.settings = settings
    }

    var shouldShowOnboarding: Bool {
        !settings.hasSeenOnboarding
    }

    /// Call once onboarding finishes; true exactly once per install.
    func consumeFirstTimeTipsAlert() -> Bool {
        guard !settings.tipsAlertShown else { return false }
        settings.tipsAlertShown = true
        return true
    }

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
