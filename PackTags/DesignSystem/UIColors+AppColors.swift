import UIKit
import SwiftUI
//MARK: - Analytics New Colors

extension Color {
    static let mphStart = Color("Color-BkgdGrad1")
    static let mphEnd = Color("Color-BkgdGrad2")
    
    // Shadows
    static let lowerShadow = Color((UIColor(named: "Color-BkgdSh1")?.withAlphaComponent(0.5))!)
    
    static let upperShadow = Color(UIColor(named: "Color-BkgdSh2")!)
    
    // Fill background
    static let bgFillColor = Color(bkgdColor)
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
    static let shadowDark1 = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
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

    /// The blue badge behind tag counts (theme list) and pack sizes (pack list).
    static let tagBadgeBlue = UIColor(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

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
