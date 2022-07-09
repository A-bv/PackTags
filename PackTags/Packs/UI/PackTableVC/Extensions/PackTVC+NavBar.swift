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
        let alpha = getNavigationBarAlphaForNavBarOpacity(offset: offset)
    
        setNavBarOpacityAndColors(alpha: alpha)
        bounceImage(offset: offset)
    }
}

extension PackTableVC {
    func bounceImage(offset: CGFloat) {
        if offset < -UIScreen.main.bounds.height/2 {
            uiiv.frame.size.height = -offset + cR
        } else {
            uiiv.frame.size.height = uiiv.frame.height
        }
    }
    
    //color and opacity variations
    func setNavBarOpacityAndColors(alpha: CGFloat) {
        self.setNavBarTransparent(alpha: alpha)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func getNavigationBarAlphaForNavBarOpacity(offset:CGFloat) -> CGFloat {
        let pos = currentNavBarHeight + 2*statusBarHeight
        let denominator: CGFloat = 50 //offset treshold
        let value = (offset + CGFloat(pos)) / denominator
        let alpha = min(1, value)
        return alpha
    }

    //MARK: - Status bar
    /*
    func statusBarTextColor(alpha:CGFloat){
        if alpha >= 0 {
            currentStatusBarStyle = .default
            setNeedsStatusBarAppearanceUpdate()
        } else {
            currentStatusBarStyle = .lightContent
            setNeedsStatusBarAppearanceUpdate()
        }
    }*/
}
