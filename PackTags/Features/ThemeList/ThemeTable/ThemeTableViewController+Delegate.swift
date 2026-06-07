//
//  ThemeTVC+Delegate.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 04.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.isUserInteractionEnabled = false //(fix p1)
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
            presentDeletionSafeAlert(indexpath: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return false }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.tableView.isEditing == true ? .none : .delete }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        reorderRow(initial: sourceIndexPath, final: destinationIndexPath)
    }
    
    override func setEditing (_ editing:Bool, animated:Bool) {
        super.setEditing(editing,animated:animated)
        showEditButton()
    }
}

extension ThemeTableViewController {
    private func makeCell(indexPath: IndexPath) -> UITableViewCell {
        guard 
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as? ThemeCell
        else {
            fatalError("The dequeued cell is not an instance of ThemeTableViewCell.")
        }
        let theme = viewModel.themes[indexPath.row]
        cell.nameLabel.text = theme.name
        if let thumbnail = theme.thumbnail {
            cell.themeImageView.image = UIImage(data: thumbnail)
        }
        return cell
    }
}
