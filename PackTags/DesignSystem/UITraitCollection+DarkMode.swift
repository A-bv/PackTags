import UIKit

extension UITraitCollection {
    /// Whether the app is currently in dark mode.
    static var isDarkMode: Bool {
        current.userInterfaceStyle == .dark
    }
}
