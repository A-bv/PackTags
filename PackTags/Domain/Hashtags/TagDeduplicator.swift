import Foundation

struct TagDeduplicator {
    private let repository: any ThemeRepositoryProtocol

    init(repository: any ThemeRepositoryProtocol) {
        self.repository = repository
    }

    func sanitize(rawText: String, currentTheme: ThemeEntity?, shuffle: Bool) -> String {
        var cleanTags = deduplicated(HashtagParser.parse(rawText))

        if !cleanTags.isEmpty {
            let alreadyStored = Set(tagsAlreadyStored(among: cleanTags, excluding: currentTheme))
            cleanTags = cleanTags.filter { !alreadyStored.contains($0) }
        }

        if shuffle {
            cleanTags = cleanTags.shuffled()
        }

        return cleanTags.joined(separator: " ")
    }

    private func tagsAlreadyStored(among tags: [String], excluding theme: ThemeEntity?) -> [String] {
        guard let content = theme?.content, !content.isEmpty else {
            return repository.tagsAlreadyStored(tags: tags)
        }

        let contentTags = content
            .replacingOccurrences(of: "\n\n", with: " ")
            .components(separatedBy: " ")
        let candidates = Array(Set(tags).subtracting(contentTags))

        return repository.tagsAlreadyStored(tags: candidates)
    }

    private func deduplicated(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags.filter { seen.insert($0).inserted }
    }
}
