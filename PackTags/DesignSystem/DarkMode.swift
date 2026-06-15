import Foundation
import UIKit

enum DarkMode {
    static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
