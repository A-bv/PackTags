import Foundation

protocol ThemeRepositoryProtocol {
    func fetchAll() -> [Theme]

    /// Creates and persists a theme after the existing ones, then returns the stored value.
    @discardableResult
    func add(name: String?, content: String?, image: Data?, thumbnail: Data?) -> Theme

    /// Persists edits to the theme matched by `id`; a no-op if it no longer exists.
    func update(_ theme: Theme)

    func delete(_ theme: Theme)

    /// Rewrites every theme's stored position to match the given order.
    func reorder(_ orderedThemes: [Theme])

    func tagsAlreadyStored(tags: [String]) -> [String]
}
