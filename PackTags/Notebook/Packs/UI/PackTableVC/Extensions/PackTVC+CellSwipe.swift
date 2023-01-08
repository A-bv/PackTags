//
//  PackTVC+CellSwipe.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    private enum Strings {
        static let show = "Show".localized()
    }
    
    func addSCellSwipeAccessory (indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: Strings.show) {  (contextualAction, view, boolValue) in
            self.chosenPack = self.packs[indexPath.row]
            self.performSegue(withIdentifier: "ShowDetail", sender: UISwipeActionsConfiguration.self)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        contextItem.backgroundColor = tableView.tintColor
        return swipeActions
    }
}
