import CoreData

/// Core Data implementation over the dedicated SmartTags store.
final class CoreDataHashtagRepository: HashtagRepositoryProtocol {
    private enum Constants {
        static let retentionDays = 7 // Instagram's saved-hashtag window
    }

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func recordSearch(_ hashtag: String) {
        let stored = fetchAll()

        if let existing = stored.first(where: { $0.title == hashtag }) {
            context.delete(existing)
        }
        pruneExpired(in: stored)

        let entry = HashtagEntity(context: context)
        entry.id = UUID()
        entry.title = hashtag
        entry.addDate = Date()

        do {
            try context.save()
        } catch {
            // Revert the failed insert/deletes so they don't linger as dirty state and
            // poison the next save. The SmartTags context is used only by this flow.
            context.rollback()
            AppLogger.persistence.error(
                "Saving a searched hashtag failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Drops entries past the retention window so the saved list stays bounded and
    /// every remaining row still has time left on its countdown.
    private func pruneExpired(in stored: [HashtagEntity]) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -Constants.retentionDays, to: Date()) ?? Date()
        for hashtag in stored where (hashtag.addDate ?? Date()) < cutoff {
            context.delete(hashtag)
        }
    }

    private func fetchAll() -> [HashtagEntity] {
        let request = NSFetchRequest<HashtagEntity>(entityName: "Hashtag")

        do {
            return try context.fetch(request)
        } catch {
            AppLogger.persistence.error(
                "Failed to fetch saved hashtags: \(error.localizedDescription, privacy: .private)")
            return []
        }
    }
}
