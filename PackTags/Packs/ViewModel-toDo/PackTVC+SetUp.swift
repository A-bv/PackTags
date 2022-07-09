//
//  PackTVC+Cell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func setPackTableVC() {
        //PPP statusBarTextColor(alpha: alpha)
        loadPack()
        tableView.reloadData()
        self.navigationItem.title = theme?.name
    }
}

extension PackTableVC {
    func willAppear() {
        setupNavigationBarStyle (isWhite: true)
    }
    
    func willDisappear() {
        setupNavigationBarStyle (isWhite: false)
    }
    
    func didDisappear() {
        // UIApplication.shared.statusBarUIView?.backgroundColor = bkgdColor
    }
}

extension PackTableVC {
    func setupNavigationBarStyle (isWhite: Bool) {
        if isWhite {
            let color = UIColor.white
            let font = UIFont.systemFont(
                ofSize: 31,
                weight: UIFont.Weight.bold)
            
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font]
        } else {
            self.navigationController?.navigationBar.largeTitleTextAttributes = nil
        }
    }
}
