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
            if goInstagram {
                self.openAppURL(
                    appURL: "instagram://user?username=\(Username)",
                    webURL: "https://instagram.com/\(Username)",
                    completion: { _ in
                        if UserDefaults.standard.bool(forKey: "Keep Packs Order") == false {
                            self.copiedPacksToBottom(packIdx: packIdx)
                        }
                    }
                )
            }
        }
    }
    
    func statusAutoDirectToInstagram() {
        let username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
        let key = "goInsta"
        
        if username.isEmpty {
            Alerts.showAlertTitle(
                targetVC: self,
                title: Strings.instagram,
                message: Strings.username,
                placeholder: Strings.enterUsername
            ) { [weak self] inputName in
                let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(name, forKey: "Instagram Username")
                UserDefaults.standard.set(true, forKey: key)
                
                self?.subBtnAlert(
                    title: username,
                    message: Strings.redirectionAlertMessage + "  \n\n " + Strings.undoRedirection
                )
            }
        }
        
        let isGoInstaEnabled = UserDefaults.standard.bool(forKey: key)

        if isGoInstaEnabled {
            UserDefaults.standard.set(false, forKey: key)
            subBtnAlert(title: username, message: Strings.stopRedirectionAlertMessage)
        } else if !username.isEmpty {
            UserDefaults.standard.set(true, forKey: key)
            subBtnAlert(title: username, message: Strings.redirectionAlertMessage)
        }
    }
}
