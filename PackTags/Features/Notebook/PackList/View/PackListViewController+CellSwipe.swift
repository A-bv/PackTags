import UIKit
import SwiftUI

extension PackListViewController {
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
