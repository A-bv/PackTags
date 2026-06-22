import UIKit
import SwiftUI

extension Color {
    /// Purple brand tint, shared with `UIColor.customPurple`.
    static let brandPurple = Color(UIColor.customPurple)

    // MARK: - Neumorphic gradient
    static let mphStart = Color("Color-BkgdGrad1")
    static let mphEnd = Color("Color-BkgdGrad2")
    static let upperShadow = Color("Color-BkgdSh2")

    // Semantically-named color assets — `brandAccent`, `brandAccentDeep`,
    // `brandAccentLight`, `facebookBlue`, `lowerShadow` — are reached through their
    // generated `Color` symbols, so they need no alias here.

    // MARK: - Fill background
    static let bgFillColor = Color(UIColor.colorBkgd)
    static let statsFillColor = bgFillColor
}
