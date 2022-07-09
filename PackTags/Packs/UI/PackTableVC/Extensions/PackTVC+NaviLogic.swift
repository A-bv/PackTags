//
//  PackTVC+NavigationLogic.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func navigationToThemeDetails (segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier = segue.identifier ?? ""
        switch(segueIdentifier) {
        case "ShowDetail":
            
            guard let navigationVC = segue.destination as? UINavigationController, let themeDetailViewController = navigationVC.topViewController as? ThemeVC
            else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let selectedTheme = theme
            themeDetailViewController.theme = selectedTheme
            themeDetailViewController.isNotNewTheme = true
            
            //checks if segue is triggered "show" button
            if sender as? Any.Type == UISwipeActionsConfiguration.self {
                themeDetailViewController.isFromShow = true
                themeDetailViewController.packFromShow = chosenPack
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}
