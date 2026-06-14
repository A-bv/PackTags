import UIKit

extension ThemeListViewController {
    private enum Strings {
        static let deleteConfirmationMessage = "Delete this theme?\n\nThis action is unreversible.".localized()
        static let yes = "Yes".localized()
        static let cancel = "Cancel".localized()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pushViewController updates the stack synchronously, so a second fast
        // tap fails this guard instead of pushing the screen twice.
        guard navigationController?.topViewController === self else { return }
        coordinator?.showPackList(for: viewModel.themes[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return makeCell(indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeletionSafeAlert(indexPath: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.tableView.isEditing == true ? .none : .delete
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.reorderTheme(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateEditButton()
    }
}

extension ThemeListViewController {
    // MARK: - Edit operations
    private func presentDeletionSafeAlert(indexPath: IndexPath) {
        let deleteAction = UIAlertAction(title: Strings.yes, style: .default) { [weak self] _ in
            self?.viewModel.deleteTheme(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
        }
        let cancelAction = UIAlertAction(title: Strings.cancel, style: .cancel)
        
        Alerts.show(
            from: self,
            title: "",
            message: Strings.deleteConfirmationMessage,
            actions: [deleteAction, cancelAction],
            preferred: cancelAction)
    }

    private func updateEditButton() {
        navigationItem.leftBarButtonItems = isEditing ? [settingsButton, editButtonItem] : [settingsButton]
    }

    private func makeCell(indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as? ThemeCell
        else {
            fatalError("The dequeued cell is not an instance of ThemeTableViewCell.")
        }
        let theme = viewModel.themes[indexPath.row]
        cell.nameLabel.text = theme.name
        cell.themeImageView.image = thumbnail(for: theme)
        return cell
    }
}
