//
//  TVC+Alerts.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 29.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//
// Works with Utility.swift

extension ThemeVC {
    func showGiveThemeNameAlert () {
        let tips = ""
        let title = themeTitle.isEmpty == true ? "New Theme" : themeTitle
        let message = themeTitle.isEmpty == true ? tips : "Edit Name"
        let placeholder = themeTitle.isEmpty == true ? "Enter Name" : "Enter New Name"
        
        Alerts.alertTitle(targetVC: self, title: title, message: message, placeholder: placeholder) {[weak vc = self]
            (inputName) in
            
            vc?.themeTitle = inputName
            vc?.updateSaveButtonState()
        }
    }
}
