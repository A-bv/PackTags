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
        guard let content = theme?.content else {
            packs = []
            return
        }
        
        let numTagsPerPack = QuantityPickerData.selectedValue
        packs = Unique.reorganizeTags(from: content, with: numTagsPerPack).components(separatedBy: "\n\n")
    }

    func updatePackListViewController() {
        loadPacks()
        tableView.reloadData()
        navigationItem.title = theme?.name
        DispatchQueue.main.async {
            // TODO: Check if can only update image
            self.setupTableViewBackgroundImage()
        }
    }
}
