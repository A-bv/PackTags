//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func handleSelectedThemeData(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationVC = segue.destination as? UINavigationController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let themeDetailViewController = navigationVC.topViewController as? ThemeVC else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        let selectedTheme = theme
        themeDetailViewController.theme = selectedTheme
        themeDetailViewController.isNotNewTheme = true
        
        if sender as? Any.Type == UISwipeActionsConfiguration.self {
            themeDetailViewController.isFromShow = true
            themeDetailViewController.packFromShow = chosenPack
        }
        
        func navigateToShowDetails() {
            self.performSegue(
                withIdentifier: PackTableVCSegueOrigin.showDetail.rawValue,
                sender: UISwipeActionsConfiguration.self)
        }
    }
}

