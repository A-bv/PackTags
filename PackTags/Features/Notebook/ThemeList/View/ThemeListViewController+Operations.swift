import UIKit

// MARK: - Reorder theme
extension ThemeListViewController {
    func reorderRow(initial: IndexPath, final: IndexPath) {
        viewModel.reorderTheme(from: initial.row, to: final.row)
    }
}

// MARK: - Delete theme + alert
extension ThemeListViewController {
    private enum Strings {
        static let deleteConfirmationMessage = "Delete this theme?\n\nThis action is unreversible.".localized()
        static let yes = "Yes".localized()
        static let cancel = "Cancel".localized()
    }
    
    func presentDeletionSafeAlert(indexpath: IndexPath) {
        let deleteAction = UIAlertAction(
            title: Strings.yes,
            style: .default
        ) { [weak self] _ in self?.deleteRow(indexPath: indexpath) }

        let cancelAction = UIAlertAction(
            title: Strings.cancel,
            style: .cancel,
            handler: nil)
        
        Alerts.show(
            from: self,
            title: "",
            message: Strings.deleteConfirmationMessage,
            actions: [deleteAction, cancelAction],
            preferred: cancelAction)
    }
    
    func handleNewUserFlow() {
        guard viewModel.shouldShowOnboarding else { return }

        coordinator?.showOnboarding { [weak self] in
            guard let self, self.viewModel.consumeFirstTimeTipsAlert() else { return }
            Alerts.showFirstTimeTipsAlert(from: self)
        }
    }

    private func deleteRow(indexPath: IndexPath) {
        viewModel.deleteTheme(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .none)
    }
}

extension ThemeListViewController {
    func showEditButton() {
        navigationItem.leftBarButtonItems = self.isEditing ? [settingsButton, editButtonItem] : [settingsButton]
    }
}
