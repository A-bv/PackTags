@preconcurrency import CoreData
import os

/// Process-wide cache of managed object models. A model must be loaded only
/// once per process — loading the same `.momd` twice registers duplicate
/// NSEntityDescriptions for the same NSManagedObject subclasses and breaks
/// entity resolution (notably when the parallel test suite creates many
/// short-lived containers).
///
/// The lock holds the cache, so concurrent access is genuinely serialized
/// rather than merely assumed safe.
private let modelCache = OSAllocatedUnfairLock(initialState: [String: NSManagedObjectModel]())

private func sharedModel(named name: String) -> NSManagedObjectModel? {
    modelCache.withLock { cache in
        if let cached = cache[name] { return cached }
        guard let url = Bundle.main.url(forResource: name, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else { return nil }
        cache[name] = model
        return model
    }
}

final class PersistenceController {
    private let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    private(set) var loadError: Error?

    init(modelName: String = "PackTags", inMemory: Bool = false) {
        if let model = sharedModel(named: modelName) {
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
