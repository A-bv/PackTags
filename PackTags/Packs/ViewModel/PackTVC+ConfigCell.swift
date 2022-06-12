//
//  PackVCConfigureCell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackCell", for: indexPath) as? PackCell
        else {
            fatalError("The dequeued cell is not an instance of Pack.")
        }
        
        let pack = self.packs[indexPath.row]
        
        // -- Labels --
        let tags = packs[indexPath.row].components(separatedBy:" ")
        cell.nameLabel.text = tags.first
        let btnLabel = tags.count != 1 ? " + \(tags.count - 1) more " : " 1 Hashtag "
        cell.subButton.setTitle(pack == "" ? " 0 Hashtags " : btnLabel, for: .normal)
        
        // -- COPY Button --
        cell.buttonTapCallback = {[weak self] in
            self?.pasteboard.string = pack
            self?.goInsta(packIdx:indexPath.row)
        }
        
        // -- SUB Button --
        cell.subButtonTapCallback = {[weak self] in
            let message = pack == "" ? "Tap the Pencil button to add Hashtags" : pack
            self?.subBtnAlert(title: "", message: message)
        }
        
        if indexPath.row == 0{
            cell.roundTopCorners(radius: cR)
        }
        
        return cell
    }
}
