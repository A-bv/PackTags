//
//  ThemeTVC+reorder.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 30.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//OPTIONAL: Reorder tableView
extension UITableViewController {
    func addLongPressToTableView () {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.8 // optional
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            self.tableView.isEditing = true
            self.setEditing(true, animated: false)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
