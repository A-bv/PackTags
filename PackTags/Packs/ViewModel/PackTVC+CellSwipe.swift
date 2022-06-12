//
//  PackTVC+CellSwipe.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func addSCellSwipeAccessory () -> [UITableViewRowAction] {
        let show = UITableViewRowAction(style: .normal, title: "Show") { (action, indexPath) in
            self.chosenPack = self.packs[indexPath.row]
            self.performSegue(withIdentifier: "ShowDetail", sender: UITableViewRowAction.self)
        }
        show.backgroundColor = tableView.tintColor
        return [show]
    }
}
