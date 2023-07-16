//
//  CellsAndThumbnailsDimentions.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UITableViewController {    
    func getThemeTableViewControllerCellHeight(
        navigationBarHeight: CGFloat,
        paddingBottom: CGFloat
    ) -> CGFloat {
        let screenHeight = view.frame.height
        let cellMinimumHeight: CGFloat = 164
        
        //tableView cells height
        var cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        }
        
        if cellHeight <= cellMinimumHeight {
            cellHeight = (screenHeight - navigationBarHeight)/3
        }
        
        return cellHeight
    }
}
