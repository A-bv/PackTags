//
//  ThemeThumbnailDimensions.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//public var thumbnailDim = CGFloat(145.33)
public var thumbnailDim = CGFloat(140.00)

extension UIViewController {
    private enum device {
        case beforeIPhone5
        case afterIPhone5
    }
    
    func setThemeTableViewControllerThumbnailsDimension() {
        let iPhoneSEWidth: CGFloat = 320
        if UIScreen.main.bounds.width <= iPhoneSEWidth {
            thumbnailDim = getCellThumbNailDimension(device: .beforeIPhone5)
        } else {
            thumbnailDim = getCellThumbNailDimension(device: .afterIPhone5)
        }
    }

    private func getCellThumbNailDimension(device: device) -> CGFloat {
        switch device {
        case .beforeIPhone5:
            return 115
        case .afterIPhone5:
            return 132
        }
    }
}
