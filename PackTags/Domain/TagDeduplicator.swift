import Foundation

/// Extracts hashtags from raw text and removes the ones already stored in other
/// themes, so a tag only ever lives in one theme.
struct TagDeduplicator {
    private let repository: any ThemeRepositoryProtocol

    init(repository: any ThemeRepositoryProtocol) {
        self.repository = repository
    }

    func sanitize(rawText: String, currentTheme: ThemeCD?, shuffle: Bool) -> String {
        var cleanTags = rawText.detectHashtags().removingDuplicates()

        if !cleanTags.isEmpty {
            let alreadyStored = tagsAlreadyStored(among: cleanTags, excluding: currentTheme)
            cleanTags = cleanTags.filter { !alreadyStored.contains($0) }
        }

        if shuffle {
            cleanTags = cleanTags.shuffled()
        }

        return cleanTags.joined(separator: " ")
    }

    /// Tags in the current theme's own content don't count as duplicates —
    /// only matches stored in *other* themes are excluded.
    private func tagsAlreadyStored(among tags: [String], excluding theme: ThemeCD?) -> [String] {
        guard let content = theme?.content, !content.isEmpty else {
            return repository.tagsAlreadyStored(tags: tags)
        }

        let contentTags = content
            .replacingOccurrences(of: "\n\n", with: " ")
            .components(separatedBy: " ")
        let tagsAlreadyInCurrentTheme = Array(Set(contentTags).intersection(Set(tags)))
        let candidates = tagsAlreadyInCurrentTheme.differenceArrays(from: tags)

        return repository.tagsAlreadyStored(tags: candidates)
    }
}
