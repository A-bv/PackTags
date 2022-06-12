//
//  PackTVC+TVHeader.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func setupTableViewImageHeader() {
        if let theme = theme, let image = theme.image {
            imageHeader(image: UIImage(data: image)!)
        }
    }
}

extension PackTableVC {
    
    func imageHeader (image:UIImage) {
        uiiv = UIImageView(image: image)
        uiiv.contentMode = .scaleAspectFill
        uiiv.clipsToBounds = true
        uiiv.layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:
                                    self.view.frame.midY + cR)
        
        //DispatchQueue.main.async {
            let tableViewBackgroundView = UIView()
            tableViewBackgroundView.addSubview(self.uiiv)
            self.tableView.backgroundView = tableViewBackgroundView
            self.uiiv.putFilter()
        //}
    }
}

extension PackTableVC {
    func TVinset () {
        let demiS = UIScreen.main.bounds.height/2
        
        //Navigation bar heights
        let largeNb = navBarHeight()
        let compactNb = navigationController?.navigationBar.frame.height ?? 0
        
        let topInset = demiS - largeNb
        let topInset2 = (demiS - compactNb) + cR + 20
        
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


/* func tableViewHeader()
 {
    //image as a TV header
    iv.image = image
    tableView.tableHeaderView = iv
 }*/
