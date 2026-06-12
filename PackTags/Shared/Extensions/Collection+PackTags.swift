import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }

    /// Elements in exactly one of the two arrays; order is not preserved.
    func symmetricDifference(with other: [Element]) -> [Element] {
        Array(Set(self).symmetricDifference(Set(other)))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        reduce(into: [:]) { counts, element in counts[element, default: 0] += 1 }
    }
}
