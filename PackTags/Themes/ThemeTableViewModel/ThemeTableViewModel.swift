//
//  T.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 30.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeTableViewModel {
    func TTVCrowHeight(vc: UIViewController) -> CGFloat {
        let btmCst = CGFloat(14) //a constant to adjust heigth at bottom
        
        //tableView cells height
        var cellHeight = (vc.view.frame.height - btmCst - vc.navigationController!.navigationBar.frame.maxY)/4
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellHeight = (vc.view.frame.height - btmCst - vc.navigationController!.navigationBar.frame.maxY)/4
        }
        
        if cellHeight <= 164 {
            cellHeight = (vc.view.frame.height - vc.navigationController!.navigationBar.frame.maxY)/3
            
            let sW = UIScreen.main.bounds.width
            if sW <= 320 {
                //Iphone5
                thumbnailDim = 115
            } else {
                //Iphone 6 to 10
                thumbnailDim = 132
            }
        }
        return cellHeight
    }
}

