import UIKit

/// A cell whose reuse identifier is derived from its type name, so call sites
/// never pass identifier strings and the register/dequeue pair can't drift apart.
protocol ReusableCellProtocol: UITableViewCell {}

extension ReusableCellProtocol {
    static var reuseIdentifier: String { String(describing: self) }
}
