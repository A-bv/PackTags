import Foundation
import UIKit

final class DarkMode {
    static func isDarkMode () -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
