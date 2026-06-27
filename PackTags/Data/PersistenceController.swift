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

    init(modelName: String = "PackTags", inMemory: Bool = false, storeURL: URL? = nil) {
        if let model = sharedModel(named: modelName) {
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: modelName)
        }

        if let description = container.persistentStoreDescriptions.first {
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            } else if let storeURL {
                // Injectable so tests can exercise a real on-disk store (e.g. `destroyStore`)
                // without touching the app's standard store location.
                description.url = storeURL
            }
        }

        var encounteredError: Error?
        container.loadPersistentStores { _, error in
            encounteredError = error
        }
        loadError = encounteredError

        if let encounteredError {
            AppLogger.persistence.fault("Failed to load persistent store '\(modelName, privacy: .public)': \(encounteredError.localizedDescription, privacy: .private)")
        }
    }

    /// Removes the on-disk store so the next launch rebuilds a clean one. The recovery path
    /// when the store fails to load (typically corruption): destructive — saved data is lost —
    /// so it's only reachable behind an explicit confirmation.
    func destroyStore() {
        guard let url = container.persistentStoreDescriptions.first?.url else { return }
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: url, type: .sqlite)
        } catch {
            AppLogger.persistence.error("Failed to destroy store: \(error.localizedDescription, privacy: .private)")
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
            AppLogger.persistence.error("Failed to save view context: \(error.localizedDescription, privacy: .private)")
            return false
        }
    }
}
