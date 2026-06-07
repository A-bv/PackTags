import Foundation

final class PackListViewModel {
    private let repository: any ThemeRepositoryProtocol
    let theme: ThemeCD
    private(set) var packs: [String] = []

    init(theme: ThemeCD, repository: any ThemeRepositoryProtocol) {
        self.theme = theme
        self.repository = repository
    }

    func loadPacks() {
        guard let content = theme.content else {
            packs = []
            return
        }
        let numTagsPerPack = QuantityPickerData.selectedValue
        packs = Unique.reorganizeTags(from: content, with: numTagsPerPack).components(separatedBy: "\n\n")
    }

    func movePack(at index: Int) {
        guard index < packs.count else { return }
        let element = packs.remove(at: index)
        packs.append(element)
        theme.content = packs.joined(separator: " ")
        repository.save()
    }
}
