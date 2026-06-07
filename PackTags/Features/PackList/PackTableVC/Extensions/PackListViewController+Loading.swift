//
//  PackTVC+Loading.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

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
