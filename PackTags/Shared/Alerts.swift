import UIKit
import SafariServices

@MainActor
enum Alerts {
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let save = UIAlertAction(title: Strings.done, style: .default) { _ in
            completion(alert.textFields?.first?.text ?? "")
        }
        save.isEnabled = false

        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
        alert.addAction(save)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.addAction(UIAction { _ in
                let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                save.isEnabled = !text.isEmpty
            }, for: .editingChanged)
        }
        targetVC.present(alert, animated: true)
    }

    static func simpleAlert(
        presentingViewController: UIViewController,
        title: String,
        message: String,
        btnAction1: UIAlertAction? = nil,
        btnAction2: UIAlertAction? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        [btnAction1, btnAction2].compactMap { $0 }.forEach(alert.addAction)
        alert.preferredAction = btnAction2
        presentingViewController.present(alert, animated: true)
    }

    static func showFirstTimeTipsAlert(presentingViewController: UIViewController) {
        let viewLater = UIAlertAction(title: Strings.viewLater, style: .default)
        let letsGo = UIAlertAction(title: Strings.letsGo, style: .default) { _ in
            guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
            presentingViewController.present(SFSafariViewController(url: url), animated: true)
        }
        simpleAlert(
            presentingViewController: presentingViewController,
            title: Strings.tricksAndTips,
            message: "\n" + Strings.discoverPacktagsWithTricksAndTips,
            btnAction1: viewLater,
            btnAction2: letsGo)
    }

    static func tapToDismiss(from presenter: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        presenter.present(alert, animated: true) {
            let tap = ClosureTapGestureRecognizer { [weak alert] in alert?.dismiss(animated: true) }
            alert.view.superview?.subviews.first?.addGestureRecognizer(tap)
        }
    }
}

private final class ClosureTapGestureRecognizer: UITapGestureRecognizer {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }

    @objc private func fire() { action() }
}
