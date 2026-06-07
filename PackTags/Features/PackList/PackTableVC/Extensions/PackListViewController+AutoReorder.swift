//
//  PackTVC+Reorder.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

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
