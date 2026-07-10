import CoreData

final class CoreDataThemeRepository: ThemeRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> [Theme] {
        let request = NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        do {
            return try context.fetch(request).map(theme(from:))
        } catch {
            AppLogger.persistence.error("Failed to fetch themes: \(error.localizedDescription, privacy: .private)")
            return []
        }
    }

    @discardableResult
    func add(name: String?, content: String?, image: Data?, thumbnail: Data?) -> Theme {
        let orderIndex = currentCount()
        let entity = ThemeEntity(context: context)
        entity.name = name
        entity.content = content
        entity.image = image
        entity.thumbnail = thumbnail
        entity.orderIndex = orderIndex
        save()
        return theme(from: entity)
    }

    func update(_ theme: Theme) {
        guard let entity = entity(for: theme.id) else { return }
        entity.name = theme.name
        entity.content = theme.content
        entity.image = theme.image
        entity.thumbnail = theme.thumbnail
        entity.orderIndex = theme.orderIndex
        save()
    }

    func delete(_ theme: Theme) {
        guard let entity = entity(for: theme.id) else { return }
        context.delete(entity)
        save()
    }

    func reorder(_ orderedThemes: [Theme]) {
        for (index, theme) in orderedThemes.enumerated() {
            entity(for: theme.id)?.orderIndex = Int32(index)
        }
        save()
    }

    func tagsAlreadyStored(tags: [String]) -> [String] {
        guard !tags.isEmpty else { return [] }

        let escaped = tags.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let request = NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")
        request.predicate = NSPredicate(format: "content MATCHES %@", ".*(\(escaped))\\b.*")

        do {
            let matchingThemes = try context.fetch(request)
            var matchedTags = Set<String>()
            for theme in matchingThemes {
                guard let content = theme.content else { continue }
                let contentTags = Set(content.components(separatedBy: " "))
                matchedTags.formUnion(contentTags.intersection(tags))
            }
            return Array(matchedTags)
        } catch {
            AppLogger.persistence.error("Failed to match stored tags: \(error.localizedDescription, privacy: .private)")
            return []
        }
    }

    // MARK: - Core Data ↔ domain

    /// Snapshots a stored record into an immutable domain value. Only the record's URI
    /// crosses the boundary as `ThemeID` — never the managed object itself.
    private func theme(from entity: ThemeEntity) -> Theme {
        Theme(
            id: ThemeID(rawValue: entity.objectID.uriRepresentation()),
            name: entity.name,
            content: entity.content,
            image: entity.image,
            thumbnail: entity.thumbnail,
            orderIndex: entity.orderIndex)
    }

    /// Resolves a `ThemeID` back to its managed object, or nil if it was deleted.
    private func entity(for id: ThemeID) -> ThemeEntity? {
        guard let coordinator = context.persistentStoreCoordinator,
              let objectID = coordinator.managedObjectID(forURIRepresentation: id.rawValue) else {
            return nil
        }
        return try? context.existingObject(with: objectID) as? ThemeEntity
    }

    private func currentCount() -> Int32 {
        let request = NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")
        do {
            return Int32(try context.count(for: request))
        } catch {
            AppLogger.persistence.error("Failed to count themes: \(error.localizedDescription, privacy: .private)")
            return 0
        }
    }

    private func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            AppLogger.persistence.error("Failed to save themes: \(error.localizedDescription, privacy: .private)")
        }
    }
}
