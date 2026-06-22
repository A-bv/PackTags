import UIKit
import SwiftUI

extension Color {
    // MARK: - Brand accent
    /// Primary brand accent — tints, icons, gauge highlights and gradient starts.
    static let brandAccent = Color("Color4")
    /// Deeper brand accent, paired with `brandAccent`/`brandAccentLight` in gradients.
    static let brandAccentDeep = Color("Color1")
    /// Lightest brand accent — the far stop of the bar-chart gradient.
    static let brandAccentLight = Color("Color")
    /// Purple brand tint, shared with `UIColor.customPurple`.
    static let brandPurple = Color(UIColor.customPurple)

    // MARK: - Neumorphic gradient
    static let mphStart = Color("Color-BkgdGrad1")
    static let mphEnd = Color("Color-BkgdGrad2")
    static let upperShadow = Color("Color-BkgdSh2")

    // `facebookBlue` and `lowerShadow` are semantically-named color assets, reached
    // through their generated `Color` symbols — no alias is needed here.

    // MARK: - Fill background
    static let bgFillColor = Color(UIColor.colorBkgd)
    static let statsFillColor = bgFillColor
}
