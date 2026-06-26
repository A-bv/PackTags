import UIKit

extension UIColor {
    /// Neumorphic dark shadow.
    static let shadowColor = asset("shadowColor", fallback: .black)
    /// Neumorphic light shadow — white in light mode, near-black in dark mode.
    static let lightShadowColor = asset("lightShadow", fallback: .white)
    /// Neumorphic bottom fill — white in light mode, black in dark mode.
    static let bottomColor = asset("bottomFill", fallback: .systemBackground)
    /// Blue badge behind pack sizes (pack list).
    static let tagBadgeBlue = asset("tagBadge", fallback: .systemBlue)
    /// Text and symbol color.
    static let customTextColor = asset("customTextColor", fallback: .label)
    /// Brand tint for navigation chrome and accessory actions (pre-dimmed to 70%).
    static let customBarTint = asset("barTint", fallback: .tintColor)

    /// Loads a named color from the asset catalog. A missing asset trips an
    /// assertion in debug (so it's caught during development) but falls back to a
    /// sensible system color in release, so a shipping build never crashes on it.
    private static func asset(_ name: String, fallback: UIColor) -> UIColor {
        guard let color = UIColor(named: name) else {
            assertionFailure("Missing color asset: \(name)")
            return fallback
        }
        return color
    }
}
