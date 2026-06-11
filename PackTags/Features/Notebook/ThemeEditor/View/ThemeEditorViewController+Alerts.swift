import UIKit

extension ThemeEditorViewController {
    private enum Strings {
        static let editName = "Edit Name".localized()
        static let enterName = "Enter Name".localized()
        static let enterNewName = "Enter New Name".localized()
        static let newTheme = "New Theme".localized()
    }

    func showNameThemeAlert() {
        let currentTitle = viewModel.themeTitle
        let title = currentTitle.isEmpty ? Strings.newTheme : currentTitle
        let message = currentTitle.isEmpty ? "" : Strings.editName
        let placeholder = currentTitle.isEmpty ? Strings.enterName : Strings.enterNewName

        Alerts.showTextInputAlert(
            targetVC: self,
            title: title,
            message: message,
            placeholder: placeholder
        ) { [weak self] inputName in
            self?.viewModel.themeTitle = inputName
            self?.updateSaveButtonState()
        }
    }
}
