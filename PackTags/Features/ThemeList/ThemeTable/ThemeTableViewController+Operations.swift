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
        themeRepository.save()
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
        
        Alerts.simpleAlert(
            presentingViewController: self,
            title: "",
            message: Strings.deleteConfirmationMessage,
            btnAction1: deleteAction,
            btnAction2: cancelAction)
    }
    
    func handleNewUserFlow() {
        if !OnboardingManager.shared.isNewUser() {
            return
        }

        coordinator?.showOnboarding {
            if !self.appSettings.tipsAlertShown {
                self.appSettings.tipsAlertShown = true
                Alerts.showFirstTimeTipsAlert(presentingViewController: self)
            }
        }
    }

    func deleteRow(indexPath: IndexPath) {
        let themeToDelete = self.themes[indexPath.row]
        themeRepository.delete(themeToDelete)
        themes = themeRepository.fetchAll()
        tableView.deleteRows(at: [indexPath], with: .none)
    }
}

extension ThemeTableViewController {
    func showEditButton() {
        navigationItem.leftBarButtonItems = self.isEditing ? [settingsButton, editButtonItem] : [settingsButton]
    }
}
