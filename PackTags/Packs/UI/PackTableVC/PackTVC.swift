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
        print("deinit")
    }
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    //Models
    var theme: ThemeCD?
    var packs = [""]
    
    //ViewModel
    let viewModel = PackTableViewModel()
    
    let pasteboard = UIPasteboard.general
    var chosenPack = String()
    
    //Image header
    var uiiv = UIImageView()
    
    //Status Bar
    var currentStatusBarStyle = UIStatusBarStyle.lightContent
    
    //Corner radius table view
    let cR = CGFloat(22)
    
    // MARK: - Interface
    override func viewWillAppear(_ animated: Bool) {willAppear()}
    override func viewWillDisappear(_ animated: Bool) {willDisappear()}
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = theme?.name
    
        loadPack() //load
        TVinset()
        setupTableViewBackgroundImage()
        tableView.backgroundColor = bkgdColor
        
        self.setNavBarTransparent(alpha: 0)
    }
    
    @IBAction func autoInstagram(_ sender: Any) {
        statusAutoDirectToInstagram ()
    }
}
