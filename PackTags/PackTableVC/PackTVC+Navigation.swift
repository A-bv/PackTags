//
//  PackTVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            case "ShowDetail":
                
                statusBarTextColor(alpha:1)
                
                guard let navigationVC = segue.destination as? UINavigationController, let themeDetailViewController = navigationVC.topViewController as? ThemeVC
                
            else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            let selectedTheme = theme
            themeDetailViewController.theme = selectedTheme
            themeDetailViewController.isNotNewTheme = true
                
            //checks if segue is triggered "show" button
            if sender as? Any.Type == UITableViewRowAction.self {
                themeDetailViewController.isFromShow = true
                themeDetailViewController.packFromShow = chosenPack
            }
                
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: - Unwind
    @IBAction func unwindToThemeList(sender: UIStoryboardSegue) {
        
        statusBarTextColor(alpha: alpha)
        
        pack()
        self.tableView.reloadData()
        self.navigationItem.title = theme?.name
            
        //Not sure if elegant
        if theme?.image != nil {
            imageHeader(image: UIImage(data:theme!.image!)!)
        } else {}
    }
    
    @IBAction func unwindFromCancel(segue: UIStoryboardSegue) {
        statusBarTextColor(alpha:alpha)
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector,
        from fromViewController: UIViewController,
        withSender sender: Any) -> Bool {
        
        return true //true = unwind segue stops here
    }
    
}
