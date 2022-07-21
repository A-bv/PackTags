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
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        let saveAction = UIAlertAction(
            title: "Done",
            style: .default
        ) { _ in
            // this code runs when the user hits the "Done" button
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
        
        //present controller
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
                handler: { _ in if okDismissVc {vc?.dismiss(animated: true, completion: nil) }
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

    class func setupTroubleShootingAlert(arr:[String?], presenterVc: UIViewController?) {
        var m = String()
        if arr == [] || arr.count >= 1 {
            m = """
                
                Login again and edit your settings:
                
                • A Creator/Business Instagram account is needed.
                
                • Only select the Facebook page that
                  is linked to your Instagram account.
                
                Tap "Setup" for more information.
                
                """
        }
        
        simpleShortAlert(
            title: "Edit Your Setup",
            message: m,
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
                let message = "\nDiscover PackTags and its purpose with \"Tricks & Tips\" in settings."
                let rvc = keyWindow?.rootViewController
                
                guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
                let vc = SFSafariViewController(url: url)
                
                let action1 = UIAlertAction(
                    title: "View later",
                    style: .default)
                
                let action2 = UIAlertAction(
                    title: "Let's go!",
                    style: .default,
                    handler: { _ in rootVC?.present(vc, animated: true)}
                )
                
                rvc?.simpleAlert(
                    title: "Tricks & Tips",
                    message: message,
                    btnAction1: action1,
                    btnAction2: action2)
            }
        }
    }
}


// MARK: - More alerts
extension UIViewController {
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
            alert.preferredAction = btnAction2
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setInstaUserAlert () {
        let username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
        let message = username == "" ? "Username" : username
        let placeholder = username == "" ? "Enter Username" : "Edit Username"
        
        //Shows alert pop up
        Alerts.alertTitle(
            targetVC: self,
            title: "Instagram" ,
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

// MARK: - Confirm row deletion
extension ThemeTableViewController {
    func presentDeletionFailsafeAlert(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: "Delete this theme?\n\nThis action is unreversible",
            preferredStyle: .alert)
        
        let yesAction = UIAlertAction(
            title: "Yes",
            style: .default
        ) { [weak self] _ in
            //Delete row code
            guard let themeToDelete = self?.themes[indexPath.row]
            else { return }
            CoreDataHelper.delete(theme: themeToDelete)
            self?.themes = CoreDataHelper.retrieveThemes()
            self?.tableView.deleteRows(at: [indexPath], with: .none)
        }
        
        alert.addAction(yesAction)
        
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

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

extension String {
    var isValidName: Bool {
        let RegEx = "^(?=.{1,30}$)(?![.])(?!.*[.]{2})[a-zA-Z0-9._]+(?<![.])$" //"^\\w{7,18}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
}
