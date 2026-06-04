//
//  PackTVC+CellSwipe.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI

extension PackTableVC {
    private enum Strings {
        static let show = "Show".localized()
    }
    
    func addSCellSwipeAccessory (indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: Strings.show) { [weak self] (contextualAction, view, boolValue) in
            guard let self else { return }
            self.chosenPack = self.packs[indexPath.row]
            self.presentThemeVC(fromSwipe: true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        contextItem.backgroundColor = UIColor(Color("CustomBarColor").opacity(0.7)) //tableView.tintColor
        return swipeActions
    }
}
