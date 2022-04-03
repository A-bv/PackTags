//
//  TVC+ActionsMenu1.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
extension ThemeVC {
    
    //SlideUpMenu (iOS < 14) 4/4
    @objc func showMenu(sender: AnyObject) {
        themeTextView.resignFirstResponder()
        showMenu()
    }
    
    //MARK: - Actions menu
    //Show title popup
    @objc func showAlert(sender: AnyObject) {
        alertTitle()
    }
    
    @objc func selectImageFromPhotoLibrary(sender: AnyObject) {
        setImagePicker()
    }
    
    //Search
    @objc func searchTags (sender: AnyObject) {
        self.themeTextView.doneTagSelection()
        MenuButton.isEnabled = false
        startToSearch()
    }
    
    @objc func shuffleTags(sender: AnyObject) {
        if let textToShuffle = themeTextView.text {
            let array = Unique.cleanList(t: textToShuffle, x:theme, shuffle: true).components(separatedBy:" ")
            themeTextView.text = Unique.packBy(t: array)
        }
    }
}
