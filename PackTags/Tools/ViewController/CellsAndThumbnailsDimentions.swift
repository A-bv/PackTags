//
//  CellsAndThumbnailsDimentions.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//public var thumbnailDim = CGFloat(145.33)
public var thumbnailDim = CGFloat(140.00)

extension UIViewController {
    enum device {
        case beforeIPhone5
        case afterIPhone5
    }
    
    func getCellThumbNailDimension (device: device) -> CGFloat {
        switch device {
        case .beforeIPhone5:
            return 115
        case .afterIPhone5:
            return 132
        }
    }
    
    func ThemeTableViewControllerCellAndThumbnailDimensions() -> CGFloat {
        let vc = self
        
        let paddingBottom = CGFloat(14)
        let navigationBarHeight = vc.navBarHeight + vc.statusBarHeight
 
        let iPhoneSEWidth: CGFloat = 320
        
        let screenHeight = vc.view.frame.height
        let cellHeightLImit: CGFloat = 164
        
        //tableView cells height
        var cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellHeight = (screenHeight  - paddingBottom - navigationBarHeight)/4
        }
        
        if cellHeight <= cellHeightLImit {
            cellHeight = (screenHeight - navigationBarHeight)/3
            if UIScreen.main.bounds.width <= iPhoneSEWidth {
                thumbnailDim = getCellThumbNailDimension(device: .beforeIPhone5)
            } else {
                thumbnailDim = getCellThumbNailDimension(device: .afterIPhone5)
            }
        }
        
        return cellHeight
    }
}
