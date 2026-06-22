import UIKit

/// Root navigation controller that lets the *topmost* view controller pick the status-bar
/// style. `UINavigationController` resolves its own style by default, which would override
/// the PackList cover's light status bar over the stretchy header.
final class StatusBarForwardingNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        viewControllers.last
    }
}
