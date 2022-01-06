//
//  Alert.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

//Alerts
class Utility: NSObject {
    
    deinit {
        print("deinit utility")
    }
    
    class func alertTitle(
        targetVC: UIViewController,
        title: String,
        message: String,
        placeholder: String,
        completion: @escaping (String) -> Void){
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Done", style: .default) { _ in
            // this code runs when the user hits the "Done" button
            let inputName = alertController.textFields![0].text
            completion(inputName ?? "was nil")
        }
       
        saveAction.isEnabled = false

        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = placeholder
            //textField.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
           
            // Enables button if textfield is not empty
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
            {_ in
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
    
        //Alert custom colors
        
        //let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        /*
        if isDarkMode() == true {
            //subview.backgroundColor = .black
        } else {
            subview.backgroundColor = UIColor(red: 246 / 255.0, green: 247 / 255.0, blue: 248 / 255.0, alpha: 1) //light grey
        }*/

        //present controller
        targetVC.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func subBtnAlert(vc:UIViewController?,title:String,message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func simpleAlert (vc:UIViewController?,title:String,message:String,btnText:String,btnText2:String?)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: btnText, style: UIAlertAction.Style.default, handler: nil))
        
        if btnText2 != nil {
            let boldAction = UIAlertAction(title: btnText2, style: UIAlertAction.Style.default, handler: { _ in self.showTricksPage()
            })
            alert.addAction(boldAction)
            alert.preferredAction = boldAction
        }
                
        // show the alert
        self.present(alert, animated: true, completion: nil)
            
    }
}

extension UIViewController {
    func setInstaUser () {
        let username = UserDefaults.standard.string(forKey: "Instagram Username")  ?? ""
        
        var message = String()
        var placeholder = String()
        
        if username == "" {
            message = "Username"
            placeholder = "Enter Username"
        } else {
            message = username
            placeholder = "Edit Username"
        }
        //print("\(UserDefaults.standard.dictionaryRepresentation())")

        //Shows alert pop up
        Utility.alertTitle(targetVC: self, title: "Instagram" , message: message, placeholder: placeholder) {
            (inputName) in
            
            let defaults = UserDefaults.standard
            let name = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults.set(name, forKey: "Instagram Username")
            
            //VARR
            ProcessJson.removeAllSavedVarData()
        }
    }
}

extension Utility {
    class func simpleShortAlert(title:String,message:String,vc:UIViewController?,okDismissVc:Bool){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
            if okDismissVc == true {
                vc?.dismiss(animated: true, completion: nil)
            } else {}
        }))
        
        if vc == nil {
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alertController, animated: true) {print("Alert from root vc")}
        } else {
            vc?.present(alertController, animated: true) {print("Short Alert")}
        }
        
    }
    
    
}

extension Utility {
    class func setupTroubleShootingAlert(arr:[String?]) {
        var m = String()
        
        if arr == [] || arr.count >= 1 {
            m = """

                Tap "Setup" for a step by step guide
                
                Login again and edit your settings:
                
                • A Creator/Business Instagram account is needed
                
                • Only select the Facebook page that
                  is linked to your Instagram account
                
                """
        }

        simpleShortAlert(title: "Edit Your Setup", message: m, vc: nil, okDismissVc: false)

        UserDefaults.standard.set(false, forKey: "isCorrectSetup")

    }
}

extension UIViewController {
    //Shown only once
    func showTipsAlert() {
        
        if !UserDefaults.standard.bool(forKey: "showTipsAlertShown") {
            UserDefaults.standard.set(true, forKey: "showTipsAlertShown")

            let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey)
            if numberOfTimesLaunched == 1 {
                let message = "\nDiscover PackTags and its purpose with \"Tricks & Tips\" in settings."
                let rvc = UIApplication.shared.keyWindow?.rootViewController
                rvc?.simpleAlert(vc: self, title: "Tricks & Tips", message: message,btnText: "View later", btnText2: "Let's go!")
                
            }
        }
    }
}

extension Utility {
    class func isDarkMode () -> Bool {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return true
            }
            else {
                return false
            }
        } else {
            return false
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
