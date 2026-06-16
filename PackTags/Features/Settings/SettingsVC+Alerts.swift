import UIKit

extension SettingsVC {
    private enum Strings {
        static let username = "Username".localized()
        static let enterUsername = "Enter Username".localized()
        static let editUsername = "Edit Username".localized()
        static let instagram = "Instagram".localized()
    }

    func setInstaUserAlert() {
        let username = viewModel.instagramUsername
        let message = username.isEmpty ? Strings.username : username
        let placeholder = username.isEmpty ? Strings.enterUsername : Strings.editUsername

        Alerts.showTextInputAlert(
            from: self,
            title: Strings.instagram,
            message: message,
            placeholder: placeholder
        ) { [weak self] inputName in
            self?.viewModel.saveInstagramUsername(inputName)
        }
    }
}
