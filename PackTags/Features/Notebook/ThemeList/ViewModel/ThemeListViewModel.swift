import Foundation

final class ThemeListViewModel {
    private let repository: any ThemeRepositoryProtocol
    private(set) var themes: [ThemeCD] = []
    var onUpdate: (() -> Void)?

    init(repository: any ThemeRepositoryProtocol) {
        self.repository = repository
    }

    func loadThemes() {
        themes = repository.fetchAll()
        onUpdate?()
    }

    func reorderTheme(from sourceIndex: Int, to destinationIndex: Int) {
        let moved = themes.remove(at: sourceIndex)
        themes.insert(moved, at: destinationIndex)
        for (i, theme) in themes.enumerated() {
            theme.orderIndex = Int32(i)
        }
        repository.save()
    }

    func deleteTheme(at index: Int) {
        let theme = themes[index]
        repository.delete(theme)
        themes = repository.fetchAll()
    }
}
