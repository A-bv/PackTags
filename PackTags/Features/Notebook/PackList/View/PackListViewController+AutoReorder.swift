import UIKit

extension PackListViewController {
    //If redirected to instagram after copy, move pack to bottom
    func copiedPacksToBottom(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.movePack(at: packIdx)
            self.tableView.reloadData()
        }
    }
}
