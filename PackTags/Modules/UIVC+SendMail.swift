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

private final class MailComposerHandler: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailComposerHandler()

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension UIViewController {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            mail.mailComposeDelegate = MailComposerHandler.shared
            mail.setToRecipients(["packtagsapp@gmail.com"])
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            print("No Email associated with this device")
        }
    }
}
