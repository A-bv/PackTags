//
//  PackTVC+Cell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func willAppear() {
        //Large title color
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(
                    ofSize: 31,
                    weight: UIFont.Weight.bold)]
        }
        
        self.tableView.backgroundColor = bkgdColor

        //nav bar color
        self.navigationController?.navigationBar.tintColor = .white
        
        //Image and tableView inset
        if theme?.image != nil {
            if let image = UIImage(data: theme!.image!) {
                TVinset()
                imageHeader(image: image)
            }
        }

    }
    
    func willDisappear() {
        //Reset title and large title colors
        let ncb = self.navigationController?.navigationBar
        ncb?.titleTextAttributes = nil
        if #available(iOS 11.0, *) {ncb?.largeTitleTextAttributes = nil}
    }
}

//MARK: - Table view styling top part
extension PackTableVC {
    
    func TVinset () {
        let demiS = UIScreen.main.bounds.height/2
        
        //Navigation bar heights
        let largeNb = navBarHeight()
        let compactNb = navigationController?.navigationBar.frame.height ?? 0
        
        //Tableview inset
        let topInset = demiS - largeNb
        tableView.contentInset = UIEdgeInsets(top: CGFloat(topInset), left: 0, bottom: 0, right: 0)
        
        //Adjust scroll view bars inset
        let topInset2 = UIScreen.main.bounds.height/2 - compactNb
        tableView.scrollIndicatorInsets = UIEdgeInsets(top:  topInset2 + cR + 20, left: 0, bottom: 0, right: 0)
    }
        
    func imageHeader (image:UIImage) {
        iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:
                                    self.view.frame.midY + cR)
        
        DispatchQueue.main.async {
            let tableViewBackgroundView = UIView()
            tableViewBackgroundView.addSubview(self.iv)
            self.tableView.backgroundView = tableViewBackgroundView
            self.iv.putFilter()
        }
        
        //image as a TV header
        //iv.image = image
        //tableView.tableHeaderView = iv
    }
 }
