//
//  ThemeTVC+Interface.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    func updateLogo (){
        if Utility.isDarkMode() == true {
            self.navigationItem.titleView = UIImageView(image: UIImage(named: "logoBlack"))
        }  else {
            self.navigationItem.titleView = UIImageView(image: UIImage(named: "logoWhite"))
        }
    }
    
    func TTVCsetUI () {
        if #available(iOS 13.0, *) {
            settingsButton.image = UIImage(systemName: "gearshape")
            analyticsButton.image = UIImage(systemName: "chart.pie")
            addThemeButton.image = UIImage(systemName: "plus")
        } else {
            settingsButton.image = UIImage(named: "gearshape")
            analyticsButton.image = UIImage(named: "chart.bar.xaxis")
            addThemeButton.image = UIImage(named: "add-Btn")
        }
        
        self.navigationController?.navigationBar.putShadow(put: true)
        
        //self.editButtonItem.image = UIImage(named: "minusv0")
        
        navigationItem.rightBarButtonItems = [addThemeButton]
        updateLogo()
        TTVCrowHeight()
        addLongPressToTableView() //reorder
    }
    
    func TTVCrefreshUI () {
        //colors
        
        self.navigationController?.setNavbarTransparent()
        self.neumorphicNavBar()
        self.navigationController?.navigationBar.tintColor = UITextView.appearance().tintColor
        self.tableView.backgroundColor = bkgdColor
 
    }
    
    func TTVCrowHeight() {
        let btmCst = CGFloat(14) //a constant to adjust heigth at bottom
        
        //tableView cells height
        var cellHeight = (self.view.frame.height - btmCst - self.navigationController!.navigationBar.frame.maxY)/4
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellHeight = (self.view.frame.height - btmCst - self.navigationController!.navigationBar.frame.maxY)/4
        }
        
        if cellHeight <= 164 {
            cellHeight = (self.view.frame.height - self.navigationController!.navigationBar.frame.maxY)/3
            
            let sW = UIScreen.main.bounds.width
            if sW <= 320 {
                //Iphone5
                thumbnailDim = 115
            } else {
                //Iphone 6 to 10
                thumbnailDim = 132
            }
        }
        self.tableView.rowHeight = cellHeight
    }
}

//OPTIONAL: Reorder tableView
extension ThemeTableViewController {
    
    func addLongPressToTableView () {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.8 // optional
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            
            if isTableViewEditMode == false {
                //activate
                self.tableView.isEditing = true
                self.setEditing(true, animated: false)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                navigationItem.rightBarButtonItems = [addThemeButton, editButtonItem]
            } else { //deactivate
            }
                
        } else {
            if (sender.state == .cancelled || sender.state == .failed || sender.state == .ended) {
                isTableViewEditMode = !isTableViewEditMode
            }
        }
    }

    //EditButtonItem actions
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if self.isEditing {}
        else {
            isTableViewEditMode = false
            navigationItem.rightBarButtonItems = [addThemeButton]
        }
    }
}

