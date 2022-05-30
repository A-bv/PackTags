//
//  ThemeTVC+Interface.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    
    func updateLogo() {
        navigationItem.titleView = DarkMode.isDarkMode() ?
        UIImageView(image: UIImage(named: "logoBlack")) :
        UIImageView(image: UIImage(named: "logoWhite"))
    }
    
    func configureNavBar () {
        if #available(iOS 13.0, *) {
            settingsButton.image = UIImage(systemName: "gearshape")
            analyticsButton.image = UIImage(systemName: "chart.pie")
            addThemeButton.image = UIImage(systemName: "plus")
        } else {
            settingsButton.image = UIImage(named: "gearshape")
            analyticsButton.image = UIImage(named: "chart.bar.xaxis")
            addThemeButton.image = UIImage(named: "add-Btn")
        }
        navigationController?.navigationBar.putShadow(put: true)
        navigationItem.rightBarButtonItems = [addThemeButton]
        updateLogo()
    }
    
    func TTVCrefreshUI () {
        self.navigationController?.setNavbarTransparent()
        self.neumorphicNavBar()
        self.navigationController?.navigationBar.tintColor = UITextView.appearance().tintColor
        self.tableView.backgroundColor = bkgdColor
    }
}
