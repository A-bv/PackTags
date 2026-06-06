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
    func copiedPacksToBottom (packIdx:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let element = self.packs.remove(at: packIdx)
            self.packs.append(element)
            self.tableView.reloadData()
            
            //save new order
            let newSt = self.packs.joined(separator: " ")
            self.theme?.content = newSt
            self.themeRepository.save()
        }
    }
}
