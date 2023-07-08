//
//  SmartGView+functions.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

// MARK: - Functions
extension InteractionBarView {
    //AAA - Just a function to print out values
    func printdd (value: Any) -> Bool {
        print(value)
        return true
    }
    
    func updateHashtag (entry: String) {
        if let index = hashtags.firstIndex(where: { $0.title == entry }) {
            moc.delete(hashtags[index])
        }
        saveHashtag(hastagTitle: entry)
    }
    
    func saveHashtag(hastagTitle: String) {
        let hashtag = Hashtag(context: moc)
        hashtag.id = UUID()
        hashtag.title = "\(hastagTitle)"
        hashtag.addDate = Date()
        try? moc.save()
    }
}
