//
//  PackTagsHelper.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05.11.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

struct Unique {
    static func packBy (t:[String]) -> String {
        let list = Array(t.chunks(of: numTagsInPack).joined(separator: ["---"])) //sections with ---
        return list.joined(separator:" ").replacingOccurrences(of: " --- ", with: "\n\n") //format
    }
    
    // MARK: - List of hashtags
    static func cleanList(rawText: String, coreDataModel: ThemeCD?, shuffle: Bool) -> String {
        
        //unique in TextView
        var cleanlist = rawText.detectHashtags().removingDuplicates()
        
        //unique in Core Data DB
        if !cleanlist.isEmpty {
            cleanlist = checkDuplicatesInCoreData(
                initialTags: cleanlist,
                themesInCoreData: coreDataModel)}
        
        //Mix tags if option is set in settings
        if UserDefaults.standard.bool(forKey: "Save & Shuffle") == true || shuffle == true {
            cleanlist = cleanlist.shuffled()
        }
        
        return cleanlist.joined(separator:" ")
    }

    static func checkDuplicatesInCoreData (
        initialTags: [String],
        themesInCoreData: ThemeCD?) -> [String] {
        var e = [""]
        
        //1,2,3: detect new added tags in textView
        if themesInCoreData?.content !=  "" && themesInCoreData?.content != nil {
            
            //get new content
            var new = themesInCoreData?.content
            
            //no line break
            new = new?.replacingOccurrences(of: "\n\n", with: " ")
            
            //1: string to list
            let a = new?.components(separatedBy:" ")
            
            //2: common elements
            let c = Array(Set(a!).intersection(Set(initialTags)))
            
            //3: difference
            let d = c.differenceArrays(from: initialTags)
            
            //check if present in Core Data
            e = CoreDataHelper.tagsAlreadyInCoreData(tags: d)
        } else {
            
            //check if present in Core Data
            e = CoreDataHelper.tagsAlreadyInCoreData(tags: initialTags)
        }
            
        print("Tags already in Core Data:", e.count)
    
        // return initial list without duplicates from core data
        return initialTags.filter { !e.contains($0) }
    }
}
    
// MARK: - Extensions
// Remove duplicates
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

// Detect hashtags in text
extension String
{
    func detectHashtags() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "((?!#\\p{Hebrew}|#\\p{Arabic})#[\\w]+)", options: .caseInsensitive)
        {
            let string = self as NSString

            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map
            {
                string.substring(with: $0.range)
            }
        }
        return []
    }
}

// Returns array of differences between 2 arrays
extension Array where Element: Hashable {
    func differenceArrays(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

// Adds element at specific position in list
extension Array {
    func chunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            let n = Swift.min(size, count - $0)
            return Array(self[$0 ..< $0 + n])
        }
    }
}

// Counts occurences of an element in a array
extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        return self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}
