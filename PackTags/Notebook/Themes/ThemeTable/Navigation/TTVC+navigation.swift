//
//  ThemeTVC+navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import os.log

extension ThemeTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            return
        }
        
        if let origin = ThemeTableViewControllerSegueOrigin(rawValue: identifier) {
            switch origin {
            case .addItem:
                os_log("Adding a new theme.", log: OSLog.default, type: .debug)
            case .showTheme:
                handleSelectedThemeData(sender: sender, destination: segue.destination)
            case .showAnalytics:
                os_log("Showing analytics.", log: OSLog.default, type: .debug)
            case .showSettings:
                os_log("Showing settings.", log: OSLog.default, type: .debug)
            }
        } else {
            fatalError("Unexpected Segue Identifier; \(String(describing: identifier))")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        shouldNavigateToShowAnalytics(segueIdentifier: identifier)
    }
}

//MARK: - Unwind
extension ThemeTableViewController {
    @IBAction func unwindToThemeList(sender: UIStoryboardSegue) {
        themes = CoreDataHelper.retrieveThemes() //theme reloads data in the didSet
    }
}
