import Foundation

/// Stable identity for a `Theme`. Opaque to the domain and presentation layers:
/// only the repository knows how to resolve it back to a stored record, which keeps
/// Core Data from leaking past the persistence boundary.
struct ThemeID: Hashable {
    let rawValue: URL
}

/// The notebook's model as a plain value type — no Core Data, no persistence.
/// Callers read and mutate an immutable snapshot; the repository is the one place
/// that maps it to and from storage.
struct Theme: Identifiable, Equatable {
    let id: ThemeID
    var name: String?
    var content: String?
    var image: Data?
    var thumbnail: Data?
    var orderIndex: Int32
}
