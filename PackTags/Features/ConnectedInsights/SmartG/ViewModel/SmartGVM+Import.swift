//
//  Import.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.01.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import InstagramGraph

// SmartG
extension SmartGViewModel {
    // 1. Api import
    func fetch(hashtag: String, onLoaded: @escaping (_ errorState: Bool) -> Void) {
        Task { @MainActor in
            do {
                let medias = try await gateway.searchHashtag(searchedHashtag: hashtag)
                dataMedias = medias
                processSmartGModel()
                onLoaded(false)
            } catch {
                AppLogger.insights.error("Hashtag search failed: \(error.localizedDescription, privacy: .public)")
                onLoaded(true)
            }
        }
    }
}
