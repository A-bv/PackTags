import UIKit

/// A `UITapGestureRecognizer` that invokes a closure on tap, so call sites don't
/// need a `@objc` target/action pair.
final class ClosureTapGestureRecognizer: UITapGestureRecognizer {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }

    @objc private func fire() { action() }
}
