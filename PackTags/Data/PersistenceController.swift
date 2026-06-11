import CoreData

final class PersistenceController {
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    private(set) var loadError: Error?

    init(modelName: String = "PackTags", inMemory: Bool = false) {
        container = NSPersistentContainer(name: modelName)

        if inMemory, let description = container.persistentStoreDescriptions.first {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        var encounteredError: Error?
        container.loadPersistentStores { _, error in
            encounteredError = error
        }
        loadError = encounteredError

        if let encounteredError {
            AppLogger.persistence.fault("Failed to load persistent store '\(modelName, privacy: .public)': \(encounteredError.localizedDescription, privacy: .public)")
        }
    }

    @discardableResult
    func saveIfNeeded() -> Bool {
        let context = container.viewContext
        guard context.hasChanges else { return true }

        do {
            try context.save()
            return true
        } catch {
            AppLogger.persistence.error("Failed to save view context: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
}
