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
        
        switch(segue.identifier ?? "") {
            case "AddItem":
                os_log("Adding a new theme.", log: OSLog.default, type: .debug)
            
            case "ShowTheme":
                guard let themeDetailViewController = segue.destination as? PackTableVC else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
             
                guard let selectedThemeCell = sender as? ThemeCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
             
                guard let indexPath = tableView.indexPath(for: selectedThemeCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
             
                let selectedTheme = themes[indexPath.row]
                themeDetailViewController.theme = selectedTheme
            
            case "ShowAnalytics":
                os_log("Showing analytics.", log: OSLog.default, type: .debug)
            
            case "ShowSettings":
                os_log("Showing settings.", log: OSLog.default, type: .debug)
        
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToThemeList(sender: UIStoryboardSegue) {
        
        //Makes sure new themes are added and works with [ThemeCD](){didSet{}}
        themes = CoreDataHelper.retrieveThemes()
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Checks if insta user is defined before performing segue to analytics
        if identifier == "ShowAnalytics" {
            
            /*
            if UserDefaults.standard.string(forKey: "Instagram Username") == nil {
                self.setInstaUser()
                return false
            } else {
                return true
            }*/
            
            //->SetupCheck
            
            //JKK
            return self.isCorrectSetup()
            
            
        }

        // by default, transition
        return true
    }
    
}


