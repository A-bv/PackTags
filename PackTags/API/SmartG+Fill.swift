//
//  PrJs_SmartG_SUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

#if !arch(arm)

@available(iOS 14.0.0, *)
extension SmartG_SwiftUI {
    static func prJs_HashatgMedia (decodedJson: Media) -> String {
        
        let arrays = buildArrays_ig_hashtags_search(decodedJson: decodedJson)
        
        let total_hashtags = arrays.hashtags.filter({ $0 != []}).map { $0.joined(separator: " ")}.joined(separator: " ")
        
        return total_hashtags
    }
}

@available(iOS 14.0.0, *)
extension SmartG_SwiftUI {
    static func buildArrays_ig_hashtags_search (decodedJson: Media) -> (
        mediaType: [String?],
        caption: [String?],
        timestamp: [String?],
        mediaUrl: [String?],
        comments_count: [Int?],
        like_count: [Int?],
        hashtags: [[String]]
    )
    {
        
        let d = decodedJson
        let dataArray = d.data
        let n = dataArray.count
        
        var mediaType = [String?]()
        var caption = [String?]()
        var timestamp = [String?]()
        var media_Url = [String?]()
        var comments_count = [Int?]()
        var like_count = [Int?]()
        var hashtags = [[String]]()
        
        for i in 0..<n {
            mediaType.append(dataArray[i]?.media_type)
            caption.append(dataArray[i]?.caption)
            timestamp.append(dataArray[i]?.timestamp)
            media_Url.append(dataArray[i]?.media_url)
            comments_count.append(dataArray[i]?.comments_count)
            like_count.append(dataArray[i]?.like_count)
            
            let H = caption[i]?.hashtags().removingDuplicates()
            if H != nil {
                hashtags.append(H!)
            }
        }
    
        return (mediaType,
                caption,
                timestamp,
                media_Url,
                comments_count,
                like_count,
                hashtags)
    }
 
}
#endif
