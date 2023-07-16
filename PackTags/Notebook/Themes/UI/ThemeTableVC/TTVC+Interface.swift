//
//  ThemeTVC+Interface.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    private enum Constants {
        static let tableViewBottomPadding = CGFloat(14)
    }
    
    func updateLogo() {
        navigationItem.titleView = DarkMode.isDarkMode() ?
        UIImageView(image: UIImage(named: "logoBlack")) :
        UIImageView(image: UIImage(named: "logoWhite"))
    }
    
    func configureNavBar () {
        settingsButton.image = UIImage(systemName: "gearshape")
        analyticsButton.image = UIImage(systemName: "chart.pie")
        addThemeButton.image = UIImage(systemName: "plus")

        navigationController?.navigationBar.putShadow()
        navigationItem.rightBarButtonItems = [addThemeButton]
        updateLogo()
    }
    
    func configureTableView () {
        self.tableView.backgroundColor = bkgdColor
        
        let navigationBarHeight = currentNavBarHeight + statusBarHeight

        self.tableView.rowHeight = getThemeTableViewControllerCellHeight(
            navigationBarHeight: navigationBarHeight,
            paddingBottom: Constants.tableViewBottomPadding)
        self.setThemeTableViewControllerThumbnailsDimension()
        self.addLongPressToTableView() // reorder cells
    }
    
    func setupNavigationBarAppearance () {
        self.setNavBarAppearance(color: bkgdColor)
        self.navigationController?.navigationBar.putShadow()
        self.navigationController?.navigationBar.tintColor = UITextView.appearance().tintColor
    }
}
