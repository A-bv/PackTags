//
//  ThemeTVC+Interface.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI

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
        settingsButton.image = UIImage(systemName: "gearshape.2.fill")
        settingsButton.target = self
        settingsButton.action = #selector(didTapSettings)
        analyticsButton.image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        analyticsButton.target = self
        analyticsButton.action = #selector(didTapAnalytics)
        smartGButton.image = UIImage(systemName: "number.circle.fill")
        smartGButton.target = self
        smartGButton.action = #selector(didTapSmartG)

        navigationController?.navigationBar.putShadow()
        navigationItem.rightBarButtonItems = [analyticsButton, smartGButton]
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
        self.navigationController?.navigationBar.tintColor = UIColor(Color("CustomBarColor").opacity(0.7)) //UITextView.appearance().tintColor
    }
    
    func addFloatingButton() {
        let button = FloatingButtonFactory.createFloatingButton(onView: self.view)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
}
