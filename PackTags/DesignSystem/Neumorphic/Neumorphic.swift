import UIKit

extension UIView {
    func neumorphism (cornerRadius: CGFloat, shadowRadius: CGFloat) {
        // ------------ DARK layer
        let darkShadow = CALayer()
        darkShadow.frame = self.layer.bounds
        darkShadow.name = "darkShadow"
        darkShadow.backgroundColor = UIColor.colorBkgd.cgColor
        darkShadow.shadowColor = UIColor.shadowColor.cgColor
        darkShadow.cornerRadius = cornerRadius
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        darkShadow.shadowOffset = CGSize(width: shadowRadius, height: shadowRadius)
        darkShadow.shadowPerformanceBoost()
        self.layer.insertSublayer(darkShadow, at: 0)

        // ------------ LIGHT layer
        let lightShadow = CALayer()
        lightShadow.name = "lightShadow"
        lightShadow.frame = self.layer.bounds
        lightShadow.backgroundColor = UIColor.colorBkgd.cgColor
        lightShadow.shadowColor = UIColor.lightShadowColor.cgColor
        lightShadow.cornerRadius = cornerRadius
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        lightShadow.shadowOffset = CGSize(width: -shadowRadius, height: -shadowRadius)
        lightShadow.shadowPerformanceBoost()
        self.layer.insertSublayer(lightShadow, at: 0)
    }
    
    func addNeumorphicShadows(
        isButtonViewHeld: Bool = false,
        updateAfterShortDelay: Bool = false) {
        let value: Double = updateAfterShortDelay ? 0.2 : 0

        if isButtonViewHeld {
            for item in self.layer.sublayers ?? [] where item.name == "lightShadow" {
                item.backgroundColor = UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor
                item.shadowColor = UITraitCollection.isDarkMode ? UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor : UIColor.shadowColor.withAlphaComponent(0.50).resolvedColor(with: self.traitCollection).cgColor
            }
                
            for item in self.layer.sublayers ?? [] where item.name == "darkShadow" {
                item.backgroundColor = UIColor.bottomColor.resolvedColor(with: self.traitCollection).cgColor
                item.shadowColor = UIColor.lightShadowColor.resolvedColor(with: self.traitCollection).cgColor
            }
                
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + value) {
                for item in self.layer.sublayers ?? [] where item.name == "lightShadow" {
                    item.backgroundColor = UIColor.colorBkgd.resolvedColor(with: self.traitCollection).cgColor
                    item.shadowColor = UIColor.lightShadowColor.resolvedColor(with: self.traitCollection).cgColor
                }
                    
                for item in self.layer.sublayers ?? [] where item.name == "darkShadow" {
                    item.backgroundColor = UIColor.colorBkgd.resolvedColor(with: self.traitCollection).cgColor
                    item.shadowColor = UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor
                }
            }
        }
    }
}
