//
//  ThemeTableViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeTableViewController: UITableViewController {
    
    @IBOutlet weak var addThemeButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var analyticsButton: UIBarButtonItem!
    
    let viewModel = ThemeTableViewModel()
    
    var themes = [ThemeCD](){
        didSet {
            //reloadeding after adding a new theme (safe)
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TTVCrefreshUI()
        
        self.view.isUserInteractionEnabled = true //(fix p1)
        
        OperationQueue.main.addOperation {
            //(p1): fast clicks opens views multiple times
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureNavBar ()
        configureTableView ()
        
        themes = CoreDataHelper.retrieveThemes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Core.shared.isNewUser() {
            self.showOnboardingScreen()
        }
    }
}

//custom status bar in all view controllers (csb)
extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}



