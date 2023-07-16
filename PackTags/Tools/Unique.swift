//
//  PackTagsHelper.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05.11.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

final class Unique {
    static func reorganizeTags(from text: String, with quantity: Int) -> String {
        let packs = text.components(separatedBy: " ")
        let chunks = packs.chunked(into: quantity).map { $0.joined(separator: " ") }
        let newText = chunks.joined(separator: "\n\n")
        return newText
    }
    
    static func cleanTagList(rawText: String, coreDataModel: ThemeCD?, shuffle: Bool) -> String {
        var cleanTags = rawText.detectHashtags().removingDuplicates()
        
        if !cleanTags.isEmpty {
            cleanTags = removeDuplicatesInCoreData(initialTags: cleanTags, themesInCoreData: coreDataModel)
        }
        
        if UserDefaults.standard.bool(forKey: "Save & Shuffle") || shuffle {
            cleanTags = cleanTags.shuffled()
        }
        
        return cleanTags.joined(separator: " ")
    }

    static func removeDuplicatesInCoreData(initialTags: [String], themesInCoreData: ThemeCD?) -> [String] {
        var existingTags = [""]
        
        if let content = themesInCoreData?.content, !content.isEmpty {
            var newContent = content
            newContent = newContent.replacingOccurrences(of: "\n\n", with: " ")
            
            let contentTags = newContent.components(separatedBy: " ")
            let commonTags = Array(Set(contentTags).intersection(Set(initialTags)))
            let differentTags = commonTags.differenceArrays(from: initialTags)
            
            existingTags = CoreDataHelper.tagsAlreadyInCoreData(tags: differentTags)
        } else {
            existingTags = CoreDataHelper.tagsAlreadyInCoreData(tags: initialTags)
        }
        
        print("Tags already in Core Data:", existingTags.count)
    
        return initialTags.filter { !existingTags.contains($0) }
    }
}
    
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: Hashable {
    func differenceArrays(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            let endIndex = Swift.min(size, count - $0)
            return Array(self[$0 ..< $0 + endIndex])
        }
    }
}

extension String {
    func detectHashtags() -> [String] {
        if let regex = try? NSRegularExpression(
            pattern: "((?!#\\p{Hebrew}|#\\p{Arabic})#[\\w]+)",
            options: .caseInsensitive
        ) {
            let nsString = self as NSString
            return regex.matches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: nsString.length)
            ).map {
                nsString.substring(with: $0.range)
            }
        }
        return []
    }
}

extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        return self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}
