//
//  PackTVC+Loading.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

//MARK: - Loading
extension PackTableVC {
    func loadPack() {
        guard let content = theme?.content else {
            packs = []
            return
        }
        
        let text = content
        packs = Unique.reorganizeTagsBySavedQuantity(from: text)
        .components(separatedBy: "\n\n")
    }
}

extension PackTableVC {
    func updatePackTableVC() {
        loadPack()
        tableView.reloadData()
        navigationItem.title = theme?.name
        DispatchQueue.main.async {
            // TODO: Check if can only update image
            self.setupTableViewBackgroundImage()
        }
    }
}
