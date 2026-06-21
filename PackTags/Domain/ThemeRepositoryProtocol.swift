import Foundation

protocol ThemeRepositoryProtocol {
    func fetchAll() -> [ThemeEntity]
    func create() -> ThemeEntity
    func save()
    func delete(_ theme: ThemeEntity)
    func count() -> Int32
    func tagsAlreadyStored(tags: [String]) -> [String]
}
