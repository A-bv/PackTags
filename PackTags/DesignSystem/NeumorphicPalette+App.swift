import SwiftUI
import NeumorphicSwiftUI

extension NeumorphicPalette {
    /// The app's palette for the SwiftUI neumorphic styles. Injected at each SwiftUI
    /// root with `.neumorphicTheme(_:)`; mirrors the UIKit palette configured in
    /// `AppDelegate`. (NeumorphicSwiftUI 3.x reads the palette from the environment
    /// instead of a global `configure` call.)
    static var app: NeumorphicPalette {
        NeumorphicPalette(
            gradientStart: .mphStart,
            gradientEnd: .mphEnd,
            lowerShadow: .lowerShadow,
            upperShadow: .upperShadow,
            highlightStroke: .brandAccent,
            baseStroke: .brandAccentDeep,
            background: .bgFillColor)
    }
}
