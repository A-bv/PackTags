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

            present(mail, animated: true)
        } else {
            AppLogger.ui.info("No email account configured on this device.")
        }
    }
}
