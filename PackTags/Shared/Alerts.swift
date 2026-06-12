import UIKit
import SafariServices

// MARK: - Alerts
@MainActor
final class Alerts {
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
    
    static func showTextInputAlert(
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
        
        let textFieldHandler: (UITextField) -> Void = { textField in
            textField.placeholder = placeholder
            observeTextFieldChanges(textField: textField, placeholder: placeholder, title: title, saveAction: saveAction)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { textField in
            textFieldHandler(textField)
        }
        targetVC.present(alertController, animated: true, completion: nil)
        
        func observeTextFieldChanges(
            textField: UITextField,
            placeholder: String,
            title: String,
            saveAction: UIAlertAction
        ) {
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let isValidName = placeholder.contains("Username") && title == "Instagram" && text.isValidName
                    saveAction.isEnabled = isValidName || !text.isEmpty
                }
            }
        }
    }
    
    static func showFirstTimeTipsAlert(presentingViewController: UIViewController) {
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
        
        simpleAlert(
            presentingViewController: presentingViewController,
            title: Strings.tricksAndTips,
            message: message,
            btnAction1: action1,
            btnAction2: action2)
    }
    
    static func simpleAlert(
        presentingViewController: UIViewController,
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
        
        presentingViewController.present(alert, animated: true, completion: nil)
    }
}


// MARK: - More alerts
extension UIViewController {
    @objc private func dismissAlertController() {
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
}

fileprivate extension String {
    /// Validation for the text-input alert above: 1-30 chars, letters,
    /// numbers, dots, underscores; no leading/trailing/consecutive dots.
    var isValidName: Bool {
        let regex = "^(?=.{1,30}$)(?![.])(?!.*[.]{2})[a-zA-Z0-9._]+(?<![.])$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
