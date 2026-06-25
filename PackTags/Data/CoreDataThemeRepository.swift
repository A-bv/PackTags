import CoreData

final class CoreDataThemeRepository: ThemeRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> [ThemeEntity] {
        let request = NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            AppLogger.persistence.error("Failed to fetch themes: \(error.localizedDescription, privacy: .private)")
            return []
        }
    }

    func create() -> ThemeEntity {
        ThemeEntity(context: context)
    }

    func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            AppLogger.persistence.error("Failed to save themes: \(error.localizedDescription, privacy: .private)")
        }
    }

    func delete(_ theme: ThemeEntity) {
        context.delete(theme)
        save()
    }

    func count() -> Int32 {
        let request = NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")

        do {
            return Int32(try context.count(for: request))
        } catch {
            AppLogger.persistence.error("Failed to count themes: \(error.localizedDescription, privacy: .private)")
            return 0
        }
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
}
