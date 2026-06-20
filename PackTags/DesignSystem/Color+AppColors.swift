import UIKit
import SwiftUI

//MARK: - Analytics colors
extension Color {
    static let mphStart = Color("Color-BkgdGrad1")
    static let mphEnd = Color("Color-BkgdGrad2")

    // Shadows
    static let lowerShadow = Color((UIColor(named: "Color-BkgdSh1")?.withAlphaComponent(0.5))!)
    static let upperShadow = Color(UIColor(named: "Color-BkgdSh2")!)

    // Fill background
    static let bgFillColor = Color(UIColor.colorBkgd)
    static let statsFillColor = bgFillColor
}
