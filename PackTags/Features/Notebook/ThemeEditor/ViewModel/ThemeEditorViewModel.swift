import Foundation

final class ThemeEditorViewModel {
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    private let deduplicator: TagDeduplicator
    private(set) var theme: Theme?
    var themeTitle: String
    var tagsPerPack: Int { settings.tagsPerPack }
    var isNewTheme: Bool { theme == nil }
    var canSave: Bool { !themeTitle.isEmpty }

    init(theme: Theme?, repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.theme = theme
        self.repository = repository
        self.settings = settings
        self.deduplicator = TagDeduplicator(repository: repository)
        self.themeTitle = theme?.name ?? ""
    }

    func contentForDisplay() -> String? {
        guard let content = theme?.content else { return nil }
        return TagPackFormatter.format(content, tagsPerPack: tagsPerPack)
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
            currentThemeContent: theme?.content,
            shuffle: settings.saveAndShuffle)

        if var edited = theme {
            edited.name = themeTitle
            edited.content = text
            edited.image = imageData
            edited.thumbnail = thumbnailData
            repository.update(edited)
            theme = edited
        } else {
            theme = repository.add(name: themeTitle, content: text, image: imageData, thumbnail: thumbnailData)
        }
    }

    func shuffleContent(rawText: String) -> String {
        let cleaned = deduplicator.sanitize(rawText: rawText, currentThemeContent: theme?.content, shuffle: true)
        return TagPackFormatter.format(cleaned, tagsPerPack: tagsPerPack)
    }
}
