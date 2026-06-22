import UIKit

extension UIColor {
    /// Neumorphic dark shadow.
    static let shadowColor = UIColor(named: "shadowColor")!
    /// Neumorphic light shadow — white in light mode, near-black in dark mode.
    static let lightShadowColor = UIColor(named: "lightShadow")!
    /// Neumorphic bottom fill — white in light mode, black in dark mode.
    static let bottomColor = UIColor(named: "bottomFill")!
    /// Blue badge behind pack sizes (pack list).
    static let tagBadgeBlue = UIColor(named: "tagBadge")!
    /// Text and symbol color.
    static let customTextColor = UIColor(named: "customTextColor")!
    /// Brand tint for navigation chrome and accessory actions (pre-dimmed to 70%).
    static let customBarTint = UIColor(named: "barTint")!
}
