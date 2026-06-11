//
//  PackTVC+Instagram.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackListViewController {
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
            let goInstagram = UserDefaults.standard.bool(forKey: SettingsKey.openInstagramAfterCopy)
            let Username = UserDefaults.standard.string(forKey: SettingsKey.instagramUsername) ?? ""
            if UserDefaults.standard.bool(forKey: SettingsKey.keepPacksOrder) == false {
                self.copiedPacksToBottom(packIdx: packIdx)
            }
            if goInstagram {
                ExternalLinkOpener.openAppURL(
                    appURL: "instagram://user?username=\(Username)",
                    webURL: "https://instagram.com/\(Username)")
            }
        }
    }
    
    func statusAutoDirectToInstagram() {
        let username = UserDefaults.standard.string(forKey: SettingsKey.instagramUsername)  ?? ""
        let key = SettingsKey.openInstagramAfterCopy
        
        if username.isEmpty {
            Alerts.showTextInputAlert(
                targetVC: self,
                title: Strings.instagram,
                message: Strings.username,
                placeholder: Strings.enterUsername
            ) { [weak self] inputName in
                let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(name, forKey: SettingsKey.instagramUsername)
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
