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
    func loadPack(){
        guard let content = theme?.content else {
            packs=[]
            return
        }
        let string = Unique.packBy(t: content.components(separatedBy:" "))
        packs = string.components(separatedBy: "\n\n")
    }
}
