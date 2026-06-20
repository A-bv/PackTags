import UIKit

extension UIColor {
    static let shadowDark1 = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)

    static var shadowColor: UIColor {
        UIColor(named: "shadowColor")!
    }

    static var lightShadowColor: UIColor {
        DarkMode.isDarkMode() ? shadowDark1 : .white
    }

    static var bottomColor: UIColor {
        DarkMode.isDarkMode() ? .black : .white
    }

    /// The blue badge behind pack sizes (pack list).
    static let tagBadgeBlue = UIColor(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

    /// Text and symbol color, from the `customTextColor` asset.
    static var customTextColor: UIColor {
        UIColor(named: "customTextColor") ?? .darkGray
    }

    /// Brand tint for navigation chrome and accessory actions, from the `CustomBarColor` asset.
    static var customBarTint: UIColor {
        (UIColor(named: "CustomBarColor") ?? .customPurple).withAlphaComponent(0.7)
    }
}
