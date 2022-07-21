//
//  External.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 23/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import MessageUI
import WebKit

extension UIViewController:  MFMailComposeViewControllerDelegate {
    func openAppURL (appURL: String, webURL: String, completion: @escaping (Bool) -> Void) {
        let appURL = URL(string: appURL)!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL) { success in
                if success {
                    completion(true)
                }
            }
            
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: webURL)!
            application.open(webURL)
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            mail.mailComposeDelegate = self
            mail.setToRecipients(["packtagsapp@gmail.com"])
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            print("No Email associated with this device")
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
