import UIKit

class ThemeNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }
}
