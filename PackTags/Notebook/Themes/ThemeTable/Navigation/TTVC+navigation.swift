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
            case .showTheme:
                handleSelectedThemeData(sender: sender, destination: segue.destination)
            }
        } else {
            os_log("Unexpected segue identifier: %{public}@", log: OSLog.default, type: .error, String(describing: identifier))
        }
    }
}
