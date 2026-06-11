import Foundation

final class PackListViewModel {
    private let repository: any ThemeRepositoryProtocol
    private let settings: any AppSettingsProtocol
    let theme: ThemeCD
    private(set) var packs: [String] = []

    init(theme: ThemeCD, repository: any ThemeRepositoryProtocol, settings: any AppSettingsProtocol) {
        self.theme = theme
        self.repository = repository
        self.settings = settings
    }

    func loadPacks() {
        guard let content = theme.content else {
            packs = []
            return
        }
        packs = TagPackFormatter.packs(from: content, tagsPerPack: settings.tagsPerPack)
    }

    func movePack(at index: Int) {
        guard index < packs.count else { return }
        let element = packs.remove(at: index)
        packs.append(element)
        theme.content = packs.joined(separator: " ")
        repository.save()
    }
}
