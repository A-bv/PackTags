//
//  PackTVC+Instagram.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    
    func goInsta(packIdx: Int) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let goInstagram = UserDefaults.standard.bool(forKey: "goInsta")
            let Username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
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
            Alerts.alertTitle(targetVC: self, title: "Instagram" , message: "Username", placeholder: "Enter Username") { (inputName) in
                let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(name, forKey: "Instagram Username")
                UserDefaults.standard.set(true, forKey: "goInsta")
                
                self.subBtnAlert(
                    vc: self,
                    title: Username,
                    message: "PackTags will redirect to this account each time copy is tapped.  \n\n Tap the button again to undo."
                )
            }
        }
        
        let status = UserDefaults.standard.bool(forKey: "goInsta")
        if status == true {
            UserDefaults.standard.set(false, forKey: "goInsta")
            self.subBtnAlert(
                vc: self,
                title: Username,
                message: "PackTags will stop redirecting to this account after copy is tapped."
            )
        } else {
            if Username != "" {
                UserDefaults.standard.set(true, forKey: "goInsta")
                
                self.subBtnAlert(
                    vc: self,
                    title: Username,
                    message: "PackTags will redirect to this account each time copy is tapped."
                )
            }
        }
    }
}


