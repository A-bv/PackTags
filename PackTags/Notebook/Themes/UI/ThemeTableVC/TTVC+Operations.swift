//
//  TTVC+Operations.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 23.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// MARK: - Reorder theme
extension ThemeTableViewController {
    func reorderRow(initial: IndexPath, final: IndexPath) {
        let movedObject = self.themes[initial.row]
        themes.remove(at: initial.row)
        themes.insert(movedObject, at: final.row)
        
        for (index, element) in themes.enumerated() {
            element.orderIndex = Int32(index)
        }
        CoreDataHelper.saveTheme()
    }
}

// MARK: - Delete theme + alert
extension ThemeTableViewController {
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
        
        self.simpleAlert(
            title: "",
            message: Strings.deleteConfirmationMessage,
            btnAction1: deleteAction,
            btnAction2: cancelAction)
    }

    func deleteRow(indexPath: IndexPath) {
        let themeToDelete = self.themes[indexPath.row]
        CoreDataHelper.delete(theme: themeToDelete)
        themes = CoreDataHelper.retrieveThemes()
        tableView.deleteRows(at: [indexPath], with: .none)
    }
}

extension ThemeTableViewController {
    func showEditButton() {
        navigationItem.rightBarButtonItems = self.isEditing ? [editButtonItem, addThemeButton] : [addThemeButton]
    }
}
