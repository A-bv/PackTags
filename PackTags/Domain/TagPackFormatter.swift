import Foundation

/// Splits a flat list of hashtags into fixed-size packs for display and copying.
enum TagPackFormatter {
    static func packs(from text: String, tagsPerPack: Int) -> [String] {
        text.components(separatedBy: " ")
            .chunked(into: tagsPerPack)
            .map { $0.joined(separator: " ") }
    }

    static func format(_ text: String, tagsPerPack: Int) -> String {
        packs(from: text, tagsPerPack: tagsPerPack).joined(separator: "\n\n")
    }
}
