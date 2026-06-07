import Foundation

final class ThemeEditorViewModel {
    private let repository: any ThemeRepositoryProtocol
    private(set) var theme: ThemeCD?
    var themeTitle: String
    var numTagsPerPack: Int { QuantityPickerData.selectedValue }
    var isNewTheme: Bool { theme == nil }

    init(theme: ThemeCD?, repository: any ThemeRepositoryProtocol) {
        self.theme = theme
        self.repository = repository
        self.themeTitle = theme?.name ?? ""
    }

    func contentForDisplay() -> String? {
        guard let content = theme?.content else { return nil }
        return Unique.reorganizeTags(from: content, with: numTagsPerPack)
    }

    func save(rawText: String, imageData: Data?, thumbnailData: Data?) {
        let text = Unique.cleanTagList(
            rawText: rawText,
            coreDataModel: theme,
            themeRepository: repository,
            shuffle: false)

        if let theme = theme {
            theme.name = themeTitle
            theme.content = text
            theme.image = imageData
            theme.thumbnail = thumbnailData
            repository.save()
            StoreKitHelper.displayStoreKit()
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
        let cleaned = Unique.cleanTagList(
            rawText: rawText,
            coreDataModel: theme,
            themeRepository: repository,
            shuffle: true)
        return Unique.reorganizeTags(from: cleaned, with: numTagsPerPack)
    }
}
