import Foundation

final class CoreDataThemeRepository: ThemeRepositoryProtocol {
    func fetchAll() -> [ThemeCD] { CoreDataHelper.retrieveThemes() }
    func create() -> ThemeCD { CoreDataHelper.newTheme() }
    func save() { CoreDataHelper.saveTheme() }
    func delete(_ theme: ThemeCD) { CoreDataHelper.delete(theme: theme) }
    func count() -> Int32 { CoreDataHelper.getRecordsCount() }
    func tagsAlreadyStored(tags: [String]) -> [String] { CoreDataHelper.tagsAlreadyInCoreData(tags: tags) }
}
