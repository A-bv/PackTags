import Foundation

final class ThemeEditorViewModel {
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    private let deduplicator: TagDeduplicator
    private(set) var theme: ThemeCD?
    var themeTitle: String
    var numTagsPerPack: Int { settings.tagsPerPack }
    var isNewTheme: Bool { theme == nil }
    var canSave: Bool { !themeTitle.isEmpty }

    init(theme: ThemeCD?, repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.theme = theme
        self.repository = repository
        self.settings = settings
        self.deduplicator = TagDeduplicator(repository: repository)
        self.themeTitle = theme?.name ?? ""
    }

    func contentForDisplay() -> String? {
        guard let content = theme?.content else { return nil }
        return TagPackFormatter.format(content, tagsPerPack: numTagsPerPack)
    }

    // MARK: - Naming

    struct NameAlert: Equatable {
        let title: String
        let message: String
        let placeholder: String
    }

    var nameAlert: NameAlert {
        if themeTitle.isEmpty {
            return NameAlert(
                title: "New Theme".localized(),
                message: "",
                placeholder: "Enter Name".localized())
        }
        return NameAlert(
            title: themeTitle,
            message: "Edit Name".localized(),
            placeholder: "Enter New Name".localized())
    }

    // MARK: - Text recognition

    func contentByPrepending(recognizedText: String, to currentText: String) -> String {
        currentText.isEmpty ? recognizedText : recognizedText + "\n\n" + currentText
    }

    func save(rawText: String, imageData: Data?, thumbnailData: Data?) {
        let text = deduplicator.sanitize(
            rawText: rawText,
            currentTheme: theme,
            shuffle: settings.saveAndShuffle)

        if let theme = theme {
            theme.name = themeTitle
            theme.content = text
            theme.image = imageData
            theme.thumbnail = thumbnailData
            repository.save()
        } else {
            let index = repository.count()
            let newTheme = repository.create()
            newTheme.name = themeTitle
            newTheme.content = text
            newTheme.image = imageData
            newTheme.thumbnail = thumbnailData
            newTheme.orderIndex = index
            repository.save()
            self.theme = newTheme
        }
    }

    func shuffleContent(rawText: String) -> String {
        let cleaned = deduplicator.sanitize(rawText: rawText, currentTheme: theme, shuffle: true)
        return TagPackFormatter.format(cleaned, tagsPerPack: numTagsPerPack)
    }
}
