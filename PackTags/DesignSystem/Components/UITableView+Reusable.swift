import UIKit

/// A cell whose reuse identifier is derived from its type name, so call sites
/// never pass identifier strings and the register/dequeue pair can't drift apart.
protocol ReusableCell: UITableViewCell {}

extension ReusableCell {
    static var reuseIdentifier: String { String(describing: self) }
}

extension UITableView {
    func register<Cell: ReusableCell>(_ cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    /// Type-safe dequeue: the cell type implies the identifier, and a mismatch is a
    /// programmer error (wrong registration), so it traps rather than returning nil.
    func dequeue<Cell: ReusableCell>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue \(Cell.self) with identifier \(Cell.reuseIdentifier)")
        }
        return cell
    }
}
