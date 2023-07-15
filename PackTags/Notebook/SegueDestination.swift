//
//  SegueDestination.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

enum ThemeTableViewControllerSegueOrigin: String {
    case addItem = "addItem"
    case showTheme = "showTheme"
    case showAnalytics = "showAnalytics"
    case showSettings = "showSettings"
}

enum PackTableVCSegueOrigin: String {
    case showDetail = "showDetail"
}

enum ThemeVCSegueOrigin: String {
    case cancel = "cancel"
    case save = "save"
}
