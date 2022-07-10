//
//  PackTVC+TVHeader.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func setupTableViewBackgroundImage() {
        if let theme = theme, let imageData = theme.image, let image = UIImage(data: imageData) {
            uiiv = UIImageView(image: image)
            uiiv.contentMode = .scaleAspectFill
            uiiv.clipsToBounds = true
            uiiv.layer.frame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: self.view.frame.midY + cR)
            
                let tableViewBackgroundView = UIView()
                tableViewBackgroundView.addSubview(self.uiiv)
                tableView.backgroundView = tableViewBackgroundView
                uiiv.putFilter()
        }
    }
}

extension PackTableVC {
    func TVinset () {
        let demiS = UIScreen.main.bounds.height/2
        let navheight = 96.0 // TODO: Get max height constant
        let insetPadding = 20.0
        
        let topInset = demiS - (navheight + statusBarHeight)
        let topInset2 = (demiS - navheight) + cR + insetPadding
        
        tableView.applyTableViewTopInset(tableViewTopInset: topInset, scrollIndicatorsTopInset: topInset2)
    }
}

extension UITableView {
    func applyTableViewTopInset(
        tableViewTopInset: CGFloat,
        scrollIndicatorsTopInset: CGFloat
    ) {
        self.contentInset = UIEdgeInsets(
            top: CGFloat(tableViewTopInset), left: 0, bottom: 0, right: 0)
        
        self.scrollIndicatorInsets = UIEdgeInsets(
            top: scrollIndicatorsTopInset, left: 0, bottom: 0, right: 0)
    }
}
