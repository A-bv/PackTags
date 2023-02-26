//
//  PackController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.10.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class PackTableVC: UITableViewController {
    
    deinit {
        print("deinit PackTableVC")
    }
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    //Models
    var theme: ThemeCD?
    var packs = [""]
    
    let pasteboard = UIPasteboard.general
    var chosenPack = String()
    
    //Image header
    var uiiv = UIImageView()
    
    //Corner radius table view
    let cR = CGFloat(22)
    
    // Status Bar color && Navigation Bar
    var alpha = CGFloat(0) {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    var resetStatusBarColor = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Interface
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = theme?.name
    
        loadPack() //load
        TVinset()
        setupTableViewBackgroundImage()
        tableView.backgroundColor = bkgdColor
        
        self.setNavBarTransparent(alpha: alpha)
    }
    
    @IBAction func autoInstagram(_ sender: Any) {
        statusAutoDirectToInstagram ()
    }
}
