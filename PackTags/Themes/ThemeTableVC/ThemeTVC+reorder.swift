//
//  ThemeTVC+reorder.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 30.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

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
