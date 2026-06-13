import Foundation

enum TagPackFormatter {
    static func packs(from text: String, tagsPerPack: Int) -> [String] {
        chunked(text.components(separatedBy: " "), into: tagsPerPack)
            .map { $0.joined(separator: " ") }
    }

    static func format(_ text: String, tagsPerPack: Int) -> String {
        packs(from: text, tagsPerPack: tagsPerPack).joined(separator: "\n\n")
    }

    private static func chunked(_ tags: [String], into size: Int) -> [[String]] {
        stride(from: 0, to: tags.count, by: size).map {
            Array(tags[$0 ..< Swift.min($0 + size, tags.count)])
        }
    }
}
