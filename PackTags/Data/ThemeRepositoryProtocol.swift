import Foundation

protocol ThemeRepositoryProtocol {
    func fetchAll() -> [ThemeCD]
    func create() -> ThemeCD
    func save()
    func delete(_ theme: ThemeCD)
    func count() -> Int32
    func tagsAlreadyStored(tags: [String]) -> [String]
}
