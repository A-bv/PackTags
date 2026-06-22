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

    // Shadows
    static let lowerShadow = Color((UIColor(named: "Color-BkgdSh1")?.withAlphaComponent(0.5))!)
    static let upperShadow = Color(UIColor(named: "Color-BkgdSh2")!)

    // Fill background
    static let bgFillColor = Color(UIColor.colorBkgd)
    static let statsFillColor = bgFillColor
}
