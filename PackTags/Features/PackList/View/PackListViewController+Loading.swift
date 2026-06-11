import Foundation

//MARK: - Loading
extension PackListViewController {
    func loadPacks() {
        viewModel.loadPacks()
    }

    func updatePackListViewController() {
        loadPacks()
        tableView.reloadData()
        navigationItem.title = viewModel.theme.name
        DispatchQueue.main.async {
            self.setupTableViewBackgroundImage()
        }
    }
}
