//
//  ThemeTableViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeTableViewController: UITableViewController {

    let smartGButton = UIBarButtonItem()
    let settingsButton = UIBarButtonItem()
    let analyticsButton = UIBarButtonItem()

    var themes = [ThemeCD](){
        didSet {
            //reloadeding after adding a new theme (safe)
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBarAppearance()
        
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
        addFloatingButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewUserFlow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateRowHeightIfNeeded()
    }
}
