import CoreData

final class PersistenceController {
    /// Managed object models must be loaded once per process — a second load of
    /// the same model registers duplicate NSEntityDescriptions for the same
    /// NSManagedObject subclasses and breaks entity resolution (notably when
    /// tests create many short-lived containers).
    /// Safe across threads: built once, then only ever read.
    nonisolated(unsafe) private static let sharedModels: [String: NSManagedObjectModel] = {
        var models: [String: NSManagedObjectModel] = [:]
        for name in ["PackTags", "SmartTags"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "momd"),
               let model = NSManagedObjectModel(contentsOf: url) {
                models[name] = model
            }
        }
        return models
    }()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    private(set) var loadError: Error?

    init(modelName: String = "PackTags", inMemory: Bool = false) {
        if let model = Self.sharedModels[modelName] {
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: modelName)
        }

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
