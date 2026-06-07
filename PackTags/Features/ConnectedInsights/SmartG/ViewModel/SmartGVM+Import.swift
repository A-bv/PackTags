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
    func fetch(hashtag: String, onLoaded: @escaping (_ errorState: Bool) -> Void) {
        smartGDataProvider.searchHashtag(
            searchedHashtag: hashtag,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let medias):
                        self?.dataMedias = medias
                        self?.processSmartGModel()
                        onLoaded(false)
                    case .failure(let error):
                        print("Error fetch: \(error)")
                        onLoaded(true)
                    }
                }
            })
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}
