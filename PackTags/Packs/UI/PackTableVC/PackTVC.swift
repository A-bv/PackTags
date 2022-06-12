//
//  PackController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.10.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import os.log

class PackTableVC: UITableViewController {
    
    deinit {
        print("deinit")
    }
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    //Models
    var theme: ThemeCD?
    var packs = [""]
    
    
    let pasteboard = UIPasteboard.general
    var chosenPack = String()
    
    //Image header
    var uiiv = UIImageView()
    
    //Nav Bar
    var currentStatusBarStyle = UIStatusBarStyle.lightContent //status bar
    
    //corner radius table view
    let cR = CGFloat(22)
    
    // MARK: - Interface
    //works with (csb) in root controller
    override var preferredStatusBarStyle: UIStatusBarStyle {return currentStatusBarStyle}
    override func viewWillAppear(_ animated: Bool) {willAppear()}
    override func viewWillDisappear(_ animated: Bool) {willDisappear()}
    override func viewDidDisappear(_ animated: Bool) {didDisappear()}
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = theme?.name
    
        loadPack() //load
        TVinset()
        setupTableViewImageHeader()
        tableView.backgroundColor = bkgdColor
        
    }
    
    @IBAction func autoInstagram(_ sender: Any) {
        statusAutoDirectToInstagram ()
    }
}
