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
        static let cancel = "Cancel".localized()
        static let done = "Done".localized()
        static let discoverPacktagsWithTricksAndTips = "Discover PackTags and its features with \"Tricks & Tips\" in settings.".localized()
        static let viewLater = "View later".localized()
        static let letsGo = "Let's go!".localized()
        static let tricksAndTips = "Tricks & Tips".localized()
    }
    
    class func showAlertTitle(
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
            let inputName = alertController.textFields?.first?.text ?? ""
            completion(inputName)
        }
        
        saveAction.isEnabled = false
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
            
            // Enables button if textfield is not empty
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: OperationQueue.main) { _ in
                    let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if placeholder.contains("Username") && title == "Instagram" {
                        saveAction.isEnabled = text.isValidName
                    } else {
                        let textCount = text.count
                        let textIsNotEmpty = textCount > 0
                        saveAction.isEnabled = textIsNotEmpty
                    }
                }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        targetVC.present(alertController, animated: true, completion: nil)
    }
    
    class func simpleShortAlert(
        title: String,
        message: String,
        presentingViewController: UIViewController,
        shouldDissmissPresentingVCWhenConfirmed: Bool
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(
                title: "Ok",
                style: .cancel,
                handler: { _ in
                    if shouldDissmissPresentingVCWhenConfirmed {
                        presentingViewController.dismiss(animated: true, completion: nil)
                    }
            }))

        presentingViewController.present(alertController, animated: true)
    }
    
    class func showFirstTimeTipsAlert(presentingViewController: UIViewController) {
        let message = "\n" + Strings.discoverPacktagsWithTricksAndTips
        
        guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
        let presentedViewController = SFSafariViewController(url: url)
        
        let action1 = UIAlertAction(
            title: Strings.viewLater,
            style: .default)
        
        let action2 = UIAlertAction(
            title: Strings.letsGo,
            style: .default
        ) { _ in
            presentingViewController.present(presentedViewController, animated: true)
        }
        
        presentingViewController.simpleAlert(
            title: Strings.tricksAndTips,
            message: message,
            btnAction1: action1,
            btnAction2: action2)
    }
}


// MARK: - More alerts
extension UIViewController {
    private enum Strings {
        static let username = NSLocalizedString("Username", comment: "")
        static let enterUsername = NSLocalizedString("Enter Username", comment: "")
        static let editUsername = NSLocalizedString("Edit Username", comment: "")
        static let instagram = NSLocalizedString("Instagram", comment: "")
    }
    
    @objc func dismissAlertController() {
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
            alert.view.superview?.subviews.first?.addGestureRecognizer(tapGesture)
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
    
    func setInstaUserAlert() {
        let username = UserDefaults.standard.string(forKey: "Instagram Username") ?? ""
        let message = username.isEmpty ? Strings.username : username
        let placeholder = username.isEmpty ? Strings.enterUsername : Strings.editUsername
        
        // Shows alert pop-up
        Alerts.showAlertTitle(
            targetVC: self,
            title: Strings.instagram,
            message: message,
            placeholder: placeholder
        ) { (inputName) in
            let defaults = UserDefaults.standard
            let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults.set(name, forKey: "Instagram Username")
        }
    }
}

extension ThemeVC {
    private enum Strings {
        static let editName = NSLocalizedString("Edit Name", comment: "")
        static let enterName = NSLocalizedString("Enter Name", comment: "")
        static let enterNewName = NSLocalizedString("Enter New Name", comment: "")
        static let newTheme = NSLocalizedString("New Theme", comment: "")
    }
    
    func showGiveThemeNameAlert() {
        let tips = ""
        let title = themeTitle.isEmpty ? Strings.newTheme : themeTitle
        let message = themeTitle.isEmpty ? tips : Strings.editName
        let placeholder = themeTitle.isEmpty ? Strings.enterName : Strings.enterNewName
        
        Alerts.showAlertTitle(
            targetVC: self,
            title: title,
            message: message,
            placeholder: placeholder
        ) { [weak vc = self] (inputName) in
            vc?.themeTitle = inputName
            vc?.updateSaveButtonState()
        }
    }
}

extension String {
    var isValidName: Bool {
        let RegEx = "^(?=.{1,30}$)(?![.])(?!.*[.]{2})[a-zA-Z0-9._]+(?<![.])$" //"^\\w{7,18}$"
        let Test = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
}
