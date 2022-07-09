//
//  Styling.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UINavigationController {
    func setNavbarTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        
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
