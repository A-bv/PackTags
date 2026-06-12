import UIKit
import SwiftUI
//MARK: - Analytics New Colors

extension Color {
    // blue for gradient
    static let lightStart = Color(red: 60 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 30 / 255, green: 80 / 255, blue: 120 / 255)
    
    static let mphStart = Color("Color-BkgdGrad1")
    static let mphEnd = Color("Color-BkgdGrad2")
    
    // Shadows
    static let lowerShadow = Color((UIColor(named: "Color-BkgdSh1")?.withAlphaComponent(0.5))!)
    
    static let upperShadow = Color(UIColor(named: "Color-BkgdSh2")!)
    
    // Fill background
    static let bgFillColor = Color(bkgdColor)
    
    static let chartFillColor = bgFillColor
    static let statsFillColor = bgFillColor
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}


//MARK: - Neumorphic colors
var bkgdColor: UIColor {
    return UIColor(named: "Color-Bkgd") ?? UIColor.morphicWhite
}

extension UIColor {
    static let morphicWhite = UIColor(red: 235/255, green: 235/255, blue: 250/255, alpha: 1)
    static let shadowWhite = UIColor(red: 187/255, green: 190/255, blue: 205/255, alpha: 1)
    static let shadowDark1 = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
    static let darkMBkgdColor = UIColor.secondarySystemBackground
}

extension UIColor {
    
    static var shadowColor: UIColor {
        return  UIColor(named: "shadowColor")!
    }
    
    static var lightShadowColor: UIColor {
        return  DarkMode.isDarkMode() == true ? UIColor.shadowDark1 : UIColor.white
    }
    
    static var bottomColor: UIColor {
        return  DarkMode.isDarkMode() == true ? UIColor.black : UIColor.white
    }
    
}

//Color of text and symbols
var customTextColor: UIColor {
    return UIColor(named: "customTextColor") ?? UIColor.darkGray
}

var customPurple: UIColor {
    return UIColor(named: "customPurple") ?? UIColor.systemPurple
}

/// Brand tint for navigation chrome and accessory actions.
var customBarTint: UIColor {
    (UIColor(named: "CustomBarColor") ?? customPurple).withAlphaComponent(0.7)
}

var welcomeScreenColor: UIColor {
    return UIColor(named: "Color-OnBoardBg" ) ?? bkgdColor
}
