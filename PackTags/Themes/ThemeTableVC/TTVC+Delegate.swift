//
//  ThemeTVC+Delegate.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 04.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// MARK: - Table view delegate/ dataSource
extension ThemeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.isUserInteractionEnabled = false //(fix p1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as? ThemeCell
        else {
            fatalError("The dequeued cell is not an instance of ThemeTableViewCell.")
        }
        
        // Fetches the appropriate theme for the data source layout.
        let theme = themes[indexPath.row]
        
        cell.nameLabel.text = theme.name
            
        if theme.thumbnail != nil {
            cell.themeImageView.image = UIImage(data: theme.thumbnail!)
        }
           
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            presentDeletionSafeAlert(indexpath: indexPath)
        } else if editingStyle == .insert {}
    }
}

// MARK: - Reorder theme
extension ThemeTableViewController {
    override func setEditing (_ editing:Bool, animated:Bool) {
        super.setEditing(editing,animated:animated)
        if self.isEditing {
            navigationItem.rightBarButtonItems = [editButtonItem, addThemeButton]
        } else {
            navigationItem.rightBarButtonItems = [addThemeButton]
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return false }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.tableView.isEditing == true ? .none : .delete }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.themes[sourceIndexPath.row]
        themes.remove(at: sourceIndexPath.row)
        themes.insert(movedObject, at: destinationIndexPath.row)
        
        for (index, element) in themes.enumerated() {
            element.orderIndex = Int32(index)
        }
        CoreDataHelper.saveTheme()
    }
}

// MARK: - Delete theme + alert
extension ThemeTableViewController {
    private enum Strings {
        static let deleteConfirmationMessage = "Delete this theme?\n\nThis action is unreversible"
        static let yes = "Yes"
        static let cancel = "Cancel"
    }
    
    private func presentDeletionSafeAlert(indexpath: IndexPath) {
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

    private func deleteRow(indexPath: IndexPath) {
        let themeToDelete = self.themes[indexPath.row]
        CoreDataHelper.delete(theme: themeToDelete)
        themes = CoreDataHelper.retrieveThemes()
        tableView.deleteRows(at: [indexPath], with: .none)
    }
}
