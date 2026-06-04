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
    // NOTE: Storyboard has a misnamed segue — the analytics button uses identifier "showSettings"
    // but actually transitions to AnalyticsHostingViewController. Kept here to keep the analytics
    // tap working until step 2 of the storyboard migration (analytics + smartG) removes this segue.
    case showSettings = "showSettings"
    case showSmartG =  "showSmartG"
}

enum PackTableVCSegueOrigin: String {
    case showDetail = "showDetail"
}

enum ThemeVCSegueOrigin: String {
    case cancel = "cancel"
    case save = "save"
}
