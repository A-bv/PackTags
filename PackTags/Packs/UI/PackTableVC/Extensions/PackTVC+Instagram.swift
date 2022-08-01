//
//  PackTVC+Instagram.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    private enum Strings {
        static let instagram = "Instagram".localized()
        static let username = "Username".localized()
        static let enterUsername = "Enter Username".localized()
        static let redirectionAlertMessage = "PackTags will redirect you to this account each, time the copy button is tapped.".localized()
        static let stopRedirectionAlertMessage = "PackTags will stop redirecting you to this account, each time the copy button is tapped.".localized()
        static let undoRedirection = "Tap the button again to undo.".localized()
    }
    
    func goInsta(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let goInstagram = UserDefaults.standard.bool(forKey: "goInsta")
            let Username = UserDefaults.standard.string(forKey: "Instagram Username") ?? ""
            if goInstagram == false {} else {
                self.openAppURL(
                    appURL: "instagram://user?username=\(Username)",
                    webURL: "https://instagram.com/\(Username)",
                    completion: {_ in
                        if UserDefaults.standard.bool(forKey: "Keep Packs Order") == false {
                            self.copiedPacksToBottom(packIdx: packIdx)
                        } else {}
                    }
                )
            }
        }
    }
    
    func statusAutoDirectToInstagram () {
        let Username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
        
        if Username == "" {
            Alerts.alertTitle(
                targetVC: self,
                title: Strings.instagram,
                message: Strings.username,
                placeholder: Strings.enterUsername
            ) { (inputName) in
                let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(name, forKey: "Instagram Username")
                UserDefaults.standard.set(true, forKey: "goInsta")
                
                self.subBtnAlert(
                    title: Username,
                    message: Strings.redirectionAlertMessage + "  \n\n " + Strings.undoRedirection
                )
            }
        }
        
        let status = UserDefaults.standard.bool(forKey: "goInsta")
        if status == true {
            UserDefaults.standard.set(false, forKey: "goInsta")
            self.subBtnAlert(
                title: Username,
                message: Strings.stopRedirectionAlertMessage
            )
        } else {
            if Username != "" {
                UserDefaults.standard.set(true, forKey: "goInsta")
                
                self.subBtnAlert(
                    title: Username,
                    message: Strings.redirectionAlertMessage
                )
            }
        }
    }
}
