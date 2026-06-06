//
//  PackTableVC+Header.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 18/01/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// Fade Navigation Bar
extension PackTableVC {
    //Scroll operations
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        updateAlphaForNavBarOpacity(offset: offset)
        setNavBarOpacityAndColors()
        uiiv.bounceImage(offset: offset, constant: cR)
    }
}
    
// Navigation Bar Color and opacity variations
extension PackTableVC {
    func setNavBarOpacityAndColors() {
        self.setNavBarTransparent(alpha: alpha)
    }
    
    private func updateAlphaForNavBarOpacity(offset: CGFloat) {
        let pos = currentNavBarHeight + 2 * statusBarHeight
        let denominator: CGFloat = 50 // Offset threshold
        let value = (offset + pos) / denominator
        alpha = min(1, value)
    }
}

// Status Bar color
extension PackTableVC {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if resetStatusBarColor {
            return .default
        } else {
            return  alpha < 0 ? .lightContent : .default
        }
    }
}
