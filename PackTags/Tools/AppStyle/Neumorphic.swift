//
//  Neumorphic.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIView {
    func neumorphism (cornerRadius: CGFloat, shadowRadius: CGFloat) {
        // ------------ DARK layer
        let darkShadow = CALayer()
        darkShadow.frame = self.layer.bounds
        darkShadow.name = "darkShadow"
        darkShadow.backgroundColor = bkgdColor.cgColor
        darkShadow.shadowColor = UIColor.darkShadowColor.cgColor
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
        lightShadow.backgroundColor = bkgdColor.cgColor
        lightShadow.shadowColor = UIColor.lightShadowColor.cgColor
        lightShadow.cornerRadius = cornerRadius
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        lightShadow.shadowOffset = CGSize(width: -shadowRadius, height: -shadowRadius)
        darkShadow.shadowPerformanceBoost()
        self.layer.insertSublayer(lightShadow, at: 0)
    }
    
    func updateNeumorphicButton(hold: Bool, delay: Bool) {
        var value = Double()
        if delay == true {value = 0.2} else {value = 0}

        if hold == true {
                
            for item in self.layer.sublayers ?? [] where item.name == "lightShadow" {
                item.backgroundColor = UIColor.darkShadowColor.cgColor
                if DarkMode.isDarkMode() == false {
                    item.shadowColor = UIColor.darkShadowColor.withAlphaComponent(0.50).cgColor
                } else {
                    item.shadowColor = UIColor.darkShadowColor.cgColor
                }
            }
                
            for item in self.layer.sublayers ?? [] where item.name == "darkShadow" {
                item.backgroundColor = UIColor.bottomColor.cgColor
                item.shadowColor = UIColor.lightShadowColor.cgColor
            }
                
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + value) {
                for item in self.layer.sublayers ?? [] where item.name == "lightShadow" {
                    item.backgroundColor = bkgdColor.cgColor
                    item.shadowColor = UIColor.lightShadowColor.cgColor
                }
                    
                for item in self.layer.sublayers ?? [] where item.name == "darkShadow" {
                    item.backgroundColor = bkgdColor.cgColor
                    item.shadowColor = UIColor.darkShadowColor.cgColor
                }
            }
        }
    }
}




extension CALayer {
    func shadowPerformanceBoost() {
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
    }
}


extension UINavigationBar {
    func putShadow (put:Bool) {
        
        let nbl = self.layer
        nbl.shadowOffset = CGSize(width: 5, height: 5)
        nbl.shadowColor = UIColor.darkShadowColor.cgColor
        
        if put == true {
            nbl.shadowRadius = 5
            nbl.shadowOpacity = 0.4 //0.35
        } else {
            nbl.shadowRadius = 0
            nbl.shadowOpacity = 0.0
        }
    }
}

extension UINavigationController {
    func setNavbarTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        //self.navigationBar.isTranslucent = true
    }
}




extension UIViewController {
    func neumorphicNavBar () {
        self.navigationController?.navigationBar.backgroundColor = bkgdColor
        navigationController?.navigationBar.putShadow(put: true)
        // UIApplication.shared.statusBarUIView?.backgroundColor = bkgdColor
    }
}





//MARK: - Update colors when light/dark mode
extension ThemeCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.contentView.backgroundColor = bkgdColor
        view.updateNeumorphicButton(hold: false, delay:false)
    }
}

extension ThemeTableViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLogo ()
        self.neumorphicNavBar()
    }
}

extension PackCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.contentView.backgroundColor = bkgdColor
        copyButton.updateNeumorphicButton(hold: false,delay:false)
    }
}

extension SettingsVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.navigationController?.navigationBar.backgroundColor = bkgdColor
        // UIApplication.shared.statusBarUIView?.backgroundColor = bkgdColor
    }
}

extension PackTableVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.navigationController?.navigationBar.putShadow(put: true)
    }
}
