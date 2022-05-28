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
        if theme?.content != nil{
            if let array = theme?.content?.components(separatedBy:" ")
            {
                let string = Unique.packBy(t:array)
                packs = string.components(separatedBy: "\n\n")
            }
        } else {
            packs=[]
        }
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
    
    
    // MARK: - Delegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackCell", for: indexPath) as? PackCell
        else {
            fatalError("The dequeued cell is not an instance of Pack.")
        }
        
        let pack = self.packs[indexPath.row]
        
        // -- Labels --
        let tags = packs[indexPath.row].components(separatedBy:" ")
        cell.nameLabel.text = tags.first
        let btnLabel = tags.count != 1 ? " + \(tags.count - 1) more " : " 1 Hashtag "
        cell.subButton.setTitle(pack == "" ? " 0 Hashtags " : btnLabel, for: .normal)
        
        // -- COPY Button --
        cell.buttonTapCallback = {[weak self] in 
            self?.pasteboard.string = pack
            self?.goInsta(packIdx:indexPath.row)
        }
        
        // -- SUB Button --
        cell.subButtonTapCallback = {[weak self] in
            let message = pack == "" ? "Tap the Pencil button to add Hashtags" : pack
            self?.subBtnAlert(title: "", message: message)
        }
        
        if indexPath.row == 0{
            cell.roundCorners(corners: [.topLeft,.topRight], radius: cR)
        }
    
        return cell
    }
    
    
    //Cell swipe buttons
    override func tableView(_ tableView:UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let show = UITableViewRowAction(style: .normal, title: "Show") { (action, indexPath) in
            self.chosenPack = self.packs[indexPath.row]
            self.performSegue(withIdentifier: "ShowDetail", sender: UITableViewRowAction.self)
        }
        show.backgroundColor = tableView.tintColor
        return [show]
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return tableView.frame.size.height/6
        //return UITableView.automaticDimension //
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //pasteboard.string = packs[indexPath.row] //copy
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func autoInstagram(_ sender: Any) {
        statusAutoDirectToInstagram ()
    }
}






