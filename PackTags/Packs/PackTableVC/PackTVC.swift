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
    
    // MARK: - Variables
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    var theme: ThemeCD?
    var packs = [""]
    let pasteboard = UIPasteboard.general
    var chosenPack = String()
    
    //Image header
    var iv = UIImageView()
    var Nheight = CGFloat()
    
    //Nav Bar
    var currentStatusBarStyle = UIStatusBarStyle.lightContent //status bar
    var alpha = CGFloat()
    
    //corner radius table view
    let cR = CGFloat(22)
    
    // MARK: - Content
    //Different cell content
    func pack(){
        guard let content = theme?.content else {
            packs=[]
            return
        }
        
        let string = Unique.packBy(t: content.components(separatedBy:" "))
        packs = string.components(separatedBy: "\n\n")
    }
    
    //If redirected to instagram after copy, move pack to bottom
    func copiedPacksToBottom (packIdx:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let element = self.packs.remove(at: packIdx)
            self.packs.append(element)
            self.tableView.reloadData()
            
            //save new order
            let newSt = self.packs.joined(separator: " ")
            self.theme?.content = newSt
            CoreDataHelper.saveTheme()
        }
    }
    
    // MARK: - Interface
    //works with (csb) in root controller
    override var preferredStatusBarStyle: UIStatusBarStyle {return currentStatusBarStyle}
    override func viewWillAppear(_ animated: Bool) {willAppear()}
    override func viewWillDisappear(_ animated: Bool) {willDisappear()}
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarUIView?.backgroundColor = bkgdColor
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = theme?.name
    
        pack() //load
    }
    
    @IBAction func autoInstagram(_ sender: Any) {
        statusAutoDirectToInstagram ()
    }
}
