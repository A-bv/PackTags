import UIKit
import SafariServices

@MainActor
enum AlertPresenter {
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
        static let ok = "Ok".localized()
        static let storeErrorTitle = "Couldn't open your data".localized()
        static let storeErrorMessage = "Your saved packs couldn't be loaded. You can reset the app's data to recover — this permanently removes saved packs — or close this and try again later.".localized()
        static let resetData = "Reset data".localized()
        static let storeResetTitle = "Data reset".localized()
        static let storeResetMessage = "Please reopen PackTags to start fresh.".localized()
    }

    static func show(
        from presenter: UIViewController,
        title: String,
        message: String,
        actions: [UIAlertAction],
        preferred: UIAlertAction? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alert.addAction)
        alert.preferredAction = preferred
        presenter.present(alert, animated: true)
    }

    static func showTextInputAlert(
        from presenter: UIViewController,
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
        presenter.present(alert, animated: true)
    }

    static func showFirstTimeTipsAlert(from presenter: UIViewController) {
        let viewLater = UIAlertAction(title: Strings.viewLater, style: .default)
        let letsGo = UIAlertAction(title: Strings.letsGo, style: .default) { _ in
            guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
            presenter.present(SFSafariViewController(url: url), animated: true)
        }
        show(
            from: presenter,
            title: Strings.tricksAndTips,
            message: "\n" + Strings.discoverPacktagsWithTricksAndTips,
            actions: [viewLater, letsGo],
            preferred: letsGo)
    }

    /// Surfaces a Core Data store-load failure instead of leaving the user in a silently
    /// empty app. `onReset` is the destructive recovery (wipe the store); it's the only way
    /// back from a corrupt store, so it's styled destructive and gated behind this alert.
    static func showStoreLoadError(from presenter: UIViewController, onReset: @escaping () -> Void) {
        let reset = UIAlertAction(title: Strings.resetData, style: .destructive) { _ in onReset() }
        let cancel = UIAlertAction(title: Strings.cancel, style: .cancel)
        show(
            from: presenter,
            title: Strings.storeErrorTitle,
            message: Strings.storeErrorMessage,
            actions: [cancel, reset])
    }

    /// Confirms the store was wiped and asks the user to relaunch (the in-memory container
    /// can't be rebuilt mid-session; a fresh launch creates a clean store).
    static func showStoreResetConfirmation(from presenter: UIViewController) {
        show(
            from: presenter,
            title: Strings.storeResetTitle,
            message: Strings.storeResetMessage,
            actions: [UIAlertAction(title: Strings.ok, style: .default)])
    }

    static func tapToDismiss(from presenter: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        presenter.present(alert, animated: true) {
            let tap = ClosureTapGestureRecognizer { [weak alert] in alert?.dismiss(animated: true) }
            alert.view.superview?.subviews.first?.addGestureRecognizer(tap)
        }
    }
}
