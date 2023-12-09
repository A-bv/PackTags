//
//  PackTVC+ConfigCell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    private enum Strings {
        static let oneHashtag = "1 Hashtag".localized()
        static let more = "more".localized()
        static let zeroHashtags = "0 Hashtags".localized()
        static let tapPencil = "Tap the Pencil button to add Hashtags.".localized()
    }
    
    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PackCell", for: indexPath) as? PackCell
        else {
            fatalError("The dequeued cell is not an instance of PackCell.")
        }
        
        let pack = self.packs[indexPath.row]
        let tags = pack.components(separatedBy: " ")
        
        cell.cellLabel.text = tags.first
        let btnLabel = tags.count != 1 ? " + \(tags.count - 1) \(Strings.more) " : " \(Strings.oneHashtag) "
        cell.subButton.setTitle(pack.isEmpty ? " \(Strings.zeroHashtags) " : btnLabel, for: .normal)
        
        cell.buttonTapCallback = { [weak self] in
            self?.pasteboard.string = pack
            self?.goInsta(packIdx: indexPath.row)
        }
        
        cell.subButtonTapCallback = { [weak self] in
            let message = pack.isEmpty ? Strings.tapPencil : pack
            self?.subBtnAlert(title: "", message: message)
        }
        
        if indexPath.row == 0 {
            cell.roundTopCorners(radius: cR)
        }
        
        return cell
    }
}
