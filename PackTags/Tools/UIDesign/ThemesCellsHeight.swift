//
//  CellsAndThumbnailsDimentions.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIViewController {    
    func getThemeTableViewControllerCellHeight() -> CGFloat {
        let paddingBottom = CGFloat(14)
        let navigationBarHeight = currentNavBarHeight + statusBarHeight
        
        let screenHeight = view.frame.height
        let cellHeightLImit: CGFloat = 164
        
        //tableView cells height
        var cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        }
        
        if cellHeight <= cellHeightLImit {
            cellHeight = (screenHeight - navigationBarHeight)/3
        }
        
        return cellHeight
    }
}
