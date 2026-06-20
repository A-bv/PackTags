import UIKit

extension UITableView {
    func register<Cell: ReusableCellProtocol>(_ cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    /// Type-safe dequeue: the cell type implies the identifier, and a mismatch is a
    /// programmer error (wrong registration), so it traps rather than returning nil.
    func dequeue<Cell: ReusableCellProtocol>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue \(Cell.self) with identifier \(Cell.reuseIdentifier)")
        }
        return cell
    }
}
