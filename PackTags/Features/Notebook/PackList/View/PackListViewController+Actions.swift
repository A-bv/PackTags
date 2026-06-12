import UIKit

// MARK: - Compose & show
// MARK: - Navigation
extension PackListViewController {
    @objc func didTapCompose() {
        presentThemeVC(fromSwipe: false)
    }

    func presentThemeVC(fromSwipe: Bool) {
        overridesStatusBarToDefault = true
        coordinator?.showThemeEditor(
            for: viewModel.theme,
            fromSwipe: fromSwipe,
            chosenPack: fromSwipe ? chosenPack : "",
            onSave: { [weak self] in
                self?.updatePackListViewController()
                self?.overridesStatusBarToDefault = false
            },
            onCancel: { [weak self] in
                self?.overridesStatusBarToDefault = false
            }
        )
    }
}

// MARK: - Instagram redirect
//
//  PackListViewController+Instagram.swift
//  PackTags
//


extension PackListViewController {
    private enum Strings {
        static let instagram = "Instagram".localized()
        static let username = "Username".localized()
        static let enterUsername = "Enter Username".localized()
        static let redirectionAlertMessage = "PackTags will redirect you to this account each, time the copy button is tapped.".localized()
        static let stopRedirectionAlertMessage = "PackTags will stop redirecting you to this account, each time the copy button is tapped.".localized()
        static let undoRedirection = "Tap the button again to undo.".localized()
    }

    private enum Delay {
        /// Leaves the copy feedback visible before the app switches to Instagram.
        static let afterCopy: TimeInterval = 0.8
    }

    func goInsta(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.afterCopy) { [weak self] in
            guard let self else { return }
            let action = self.viewModel.postCopyAction()

            if action.shouldMovePackToBottom {
                self.copiedPacksToBottom(packIdx: packIdx)
            }
            if let username = action.instagramUsername {
                ExternalLinkOpener.openAppURL(
                    appURL: "instagram://user?username=\(username)",
                    webURL: "https://instagram.com/\(username)")
            }
        }
    }

    func statusAutoDirectToInstagram() {
        switch viewModel.toggleInstagramRedirect() {
        case .promptForUsername:
            promptForInstagramUsername()
        case .enabled(let username):
            subBtnAlert(title: username, message: Strings.redirectionAlertMessage)
        case .disabled(let username):
            subBtnAlert(title: username, message: Strings.stopRedirectionAlertMessage)
        }
    }

    private func promptForInstagramUsername() {
        Alerts.showTextInputAlert(
            targetVC: self,
            title: Strings.instagram,
            message: Strings.username,
            placeholder: Strings.enterUsername
        ) { [weak self] inputName in
            guard let self else { return }
            let name = self.viewModel.saveInstagramUsername(inputName)
            self.subBtnAlert(
                title: name,
                message: Strings.redirectionAlertMessage + "  \n\n " + Strings.undoRedirection
            )
        }
    }
}

// MARK: - Post-copy reorder
extension PackListViewController {
    //If redirected to instagram after copy, move pack to bottom
    private func copiedPacksToBottom(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.movePack(at: packIdx)
            self.tableView.reloadData()
        }
    }
}
