//
//  Alerts.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08/01/2022.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

// MARK: - Alerts
class Alerts: NSObject {
    private enum Links {
        static let settingsTricksAndTipsUrl = "https://sites.google.com/view/packtags-tricks-tips/accueil"
    }
    
    private enum Strings {
        static let cancel = "Cancel"
        static let done = "Done"
        static let editYourSetup = "Edit Your Setup"
        static let troubleShootingAlertMessage = """
                
                Login again and edit your settings:
                
                • A Creator/Business Instagram account is needed.
                
                • Only select the Facebook page that
                  is linked to your Instagram account.
                
                Tap "Setup" for more information.
                
                """
        static let discoverPacktagsWithTricksAndTips = "\nDiscover PackTags and its purpose with \"Tricks & Tips\" in settings."
        static let viewLater = "View later"
        static let letsGo = "Let's go!"
        static let tricksAndTips = "Tricks & Tips"
    }
    
    class func alertTitle(
        targetVC: UIViewController,
        title: String,
        message: String,
        placeholder: String,
        completion: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: Strings.cancel,
            style: .cancel,
            handler: nil)
        
        let saveAction = UIAlertAction(
            title: Strings.done,
            style: .default
        ) { _ in
            let inputName = alertController.textFields![0].text
            completion(inputName ?? "was nil")
        }
        
        saveAction.isEnabled = false
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
            
            // Enables button if textfield is not empty
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: OperationQueue.main,
                using: { _ in
                    let text = textField.text
                    if placeholder.contains("Username") == true && title == "Instagram" {
                        saveAction.isEnabled =  text?.isValidName ?? false //Valid user
                    } else {
                        let textCount = text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                        let textIsNotEmpty = textCount > 0
                        saveAction.isEnabled = textIsNotEmpty
                    }
                })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        targetVC.present(alertController, animated: true, completion: nil)
    }
    
    class func simpleShortAlert(
        title: String,
        message: String,
        vc: UIViewController?,
        okDismissVc: Bool)
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(
                title: "Ok",
                style: .cancel,
                handler: { _ in
                    if okDismissVc {
                        vc?.dismiss(animated: true, completion: nil)
                    }
        }))
        
        if vc == nil {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let rootVC = keyWindow?.rootViewController
            rootVC?.presentedViewController?.present(alertController, animated: true)
            print("Alert from root vc")
        } else {
            vc?.present(alertController, animated: true)
            print("Short Alert")
        }
    }

    class func setupTroubleShootingAlert(presenterVc: UIViewController?) {
        simpleShortAlert(
            title: Strings.editYourSetup,
            message: Strings.troubleShootingAlertMessage,
            vc: presenterVc,
            okDismissVc: false)
        UserDefaults.standard.set(false, forKey: "isCorrectSetup")
    }
    
    class func showFirstTimeTipsAlert(presentingVc: UIViewController) {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let rootVC = keyWindow?.rootViewController
        
        if !UserDefaults.standard.bool(forKey: "showTipsAlertShown") {
            UserDefaults.standard.set(true, forKey: "showTipsAlertShown")
            
            let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey)
            if numberOfTimesLaunched == 1 {
                let message = Strings.discoverPacktagsWithTricksAndTips
                let rvc = keyWindow?.rootViewController
                
                guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
                let vc = SFSafariViewController(url: url)
                
                let action1 = UIAlertAction(
                    title: Strings.viewLater,
                    style: .default)
                
                let action2 = UIAlertAction(
                    title: Strings.letsGo,
                    style: .default,
                    handler: { _ in rootVC?.present(vc, animated: true)}
                )
                
                rvc?.simpleAlert(
                    title: Strings.tricksAndTips,
                    message: message,
                    btnAction1: action1,
                    btnAction2: action2)
            }
        }
    }
}


// MARK: - More alerts
extension UIViewController {
    private enum Strings {
        static let username = "Username"
        static let enterUsername = "Enter Username"
        static let editUsername = "Edit Username"
        static let instagram = "Instagram"
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func subBtnAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func simpleAlert(
        title: String,
        message: String,
        btnAction1: UIAlertAction? = nil,
        btnAction2: UIAlertAction? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        if let btnAction1 = btnAction1 {
            alert.addAction(btnAction1)
        }
        
        if let btnAction2 = btnAction2 {
            alert.addAction(btnAction2)
        }
        
        alert.preferredAction = btnAction2
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setInstaUserAlert () {
        let username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
        let message = username == "" ? Strings.username : username
        let placeholder = username == "" ? Strings.enterUsername : Strings.editUsername
        
        //Shows alert pop up
        Alerts.alertTitle(
            targetVC: self,
            title: Strings.instagram,
            message: message,
            placeholder: placeholder
        ) {
            (inputName) in
            
            let defaults = UserDefaults.standard
            let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults.set(name, forKey: "Instagram Username")
            
            //VARR
            ProcessJson.removeAllSavedVarData()
        }
    }
}

extension ThemeVC {
    private enum Strings {
        static let editName = "Edit Name"
        static let enterName = "Enter Name"
        static let enterNewName = "Enter New Name"
        static let newTheme = "New Theme"
    }
    
    func showGiveThemeNameAlert () {
        let tips = ""
        let title = themeTitle.isEmpty == true ? Strings.newTheme : themeTitle
        let message = themeTitle.isEmpty == true ? tips : Strings.editName
        let placeholder = themeTitle.isEmpty == true ? Strings.enterName : Strings.enterNewName
        
        Alerts.alertTitle(
            targetVC: self,
            title: title,
            message: message,
            placeholder: placeholder
        ) { [weak vc = self]
            (inputName) in
            
            vc?.themeTitle = inputName
            vc?.updateSaveButtonState()
        }
    }
}

extension String {
    var isValidName: Bool {
        let RegEx = "^(?=.{1,30}$)(?![.])(?!.*[.]{2})[a-zA-Z0-9._]+(?<![.])$" //"^\\w{7,18}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
}
