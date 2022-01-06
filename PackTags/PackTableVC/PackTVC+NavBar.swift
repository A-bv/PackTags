//
//  PackTableVC+Header.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 18/01/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    
    //Scroll operations
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Fade of navigationbar
        let pos = navBarHeight()
        let denominator: CGFloat = 50 //offset treshold
        let offset = scrollView.contentOffset.y
        let value = (offset + CGFloat(pos)) / denominator
        alpha = min(1, value)
        self.setNavbar(alpha: alpha)
        
        //Image bounce
        if offset < -UIScreen.main.bounds.height/2 {
            iv.frame.size.height = -offset + cR
        } else {
            iv.frame.size.height = iv.frame.height
        }
    }
    
}

extension PackTableVC {
    
    //MARK: - Custom navigation bar
    func navBarHeight() -> CGFloat {
        if self.navigationController != nil {
            let value = self.navigationController!.navigationBar.intrinsicContentSize.height + self.navigationController!.topLayoutGuide.length

            return  value
        } else {return CGFloat(0)}
    }
    
    //color and opacity variations
    private func setNavbar(alpha: CGFloat) {
        let nc = self.navigationController?.navigationBar
        
        //Colors
        //let NBarColors = navBarMorphicColors ()
        var navBarNewColor = bkgdColor
        var navBarContentNewColor = labelColor
        
        //Nav and status bar color and transparency
        navBarNewColor = navBarNewColor.withAlphaComponent(alpha)
        if alpha >= 0 {
            //nav bar background color
            navBarContentNewColor = navBarContentNewColor.withAlphaComponent(alpha)
            
            //nav bar title
            nc?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarContentNewColor]
            
            //nav bar buttons
            nc?.tintColor = navBarContentNewColor
            
            //status bar
            currentStatusBarStyle = .default
            setNeedsStatusBarAppearanceUpdate()
        } else {
            nc?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            nc?.tintColor = .white
            currentStatusBarStyle = .lightContent
            setNeedsStatusBarAppearanceUpdate()
        }
        
        nc?.backgroundColor = navBarNewColor
        //works with statusBarUIView added in appdelegate:
        UIApplication.shared.statusBarUIView?.backgroundColor = navBarNewColor
    }
}

//MARK: - Status bar
extension PackTableVC {
    //Function used after modal screen dismissed
    func statusBarTextColor(alpha:CGFloat){
        if alpha >= 0 {
            currentStatusBarStyle = .default
            setNeedsStatusBarAppearanceUpdate()
        } else {
            currentStatusBarStyle = .lightContent
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}



