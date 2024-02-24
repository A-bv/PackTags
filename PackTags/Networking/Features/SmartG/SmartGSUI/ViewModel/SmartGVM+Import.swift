//
//  Import.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.01.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

// SmartG
extension SmartGViewModel {
    // 1. Api import
    func fetch(hashtag: String, onLoaded: @escaping () -> Void) {
        ApiService.searchHashtag(
            searchedHashtag: hashtag,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.dataMedias = result
                    self?.processSmartGModel()
                    onLoaded()
                }
            })
        
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}
