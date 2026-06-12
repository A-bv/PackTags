import Foundation

extension AppDelegate {
    /// Copies the bundled sample database into Application Support so first-time
    /// users start with example themes. Must run before the Core Data store loads.
    func seedData() {
        let fileManager = FileManager.default

        guard let seedFolderURL = Bundle.main.resourceURL?.appendingPathComponent("SeedData"),
              let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            AppLogger.lifecycle.error("Seed data source or destination unavailable.")
            return
        }

        // Replaying onboarding resets hasSeenOnboarding, so this can run on a
        // device full of user data. Never overwrite an existing store.
        let storeURL = applicationSupportURL.appendingPathComponent("PackTags.sqlite")
        guard !fileManager.fileExists(atPath: storeURL.path) else { return }

        do {
            try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true)

            for seedFile in try fileManager.contentsOfDirectory(at: seedFolderURL, includingPropertiesForKeys: nil) {
                try fileManager.copyItem(at: seedFile, to: applicationSupportURL.appendingPathComponent(seedFile.lastPathComponent))
            }
        } catch {
            AppLogger.lifecycle.error("Failed to seed sample data: \(error.localizedDescription, privacy: .public)")
        }
    }
}
