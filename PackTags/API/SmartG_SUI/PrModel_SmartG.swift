//
//  processedSmarGModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16/02/2022.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

struct processedSmartGModel: Hashable, Decodable {
    let hashtags: [String]
    
    init(hashtags: [String] = []) {
        self.hashtags = hashtags
    }
}
