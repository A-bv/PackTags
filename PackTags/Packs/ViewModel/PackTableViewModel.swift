//
//  PackTVViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class PackTableViewModel {
    func getNavigationBarStyleAttributes (isWhite: Bool) -> [NSAttributedString.Key : NSObject]? {
        let color = UIColor.white
        let font = UIFont.systemFont(
            ofSize: 31,
            weight: UIFont.Weight.bold)
        
        return isWhite ? [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font
        ] : nil
    }
}
