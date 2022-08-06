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
    
    //MARK: - List of hashtags
    
    static func cleanList(t:String,x:ThemeCD?,shuffle:Bool) -> String {
        var cleanlist = t.hashtags().removingDuplicates()//unique in TextView
        if cleanlist != [] {cleanlist = checkCD(b: cleanlist, x:x)} //unique in Core Data DB
        
        //Mix tags if option is set in settings
        if UserDefaults.standard.bool(forKey: "Save & Shuffle") == true || shuffle == true {
            cleanlist = cleanlist.shuffled()
        } else {}
        
        return cleanlist.joined(separator:" ")
    }

    //Check for duplicates in Core Data DB
    static func checkCD (b: [String],x:ThemeCD?) -> [String] {
        var e = [""]
        
        //B is content (OK)
        
        //1,2,3: detect new added tags in textView
        if x?.content !=  "" && x?.content != nil {
            var new = x?.content //get new content
            new = new?.replacingOccurrences(of: "\n\n", with: " ") //no line break
            let a = new?.components(separatedBy:" ") //1: string to list
            
            let c = Array(Set(a!).intersection(Set(b))) //2: common elements
            
            let d = c.differenceArrays(from: b)  //3: difference
            
            e = CoreDataHelper.tagsAlreadyInCoreData(tags: d) //check if present in Core Data
        } else {
            e = CoreDataHelper.tagsAlreadyInCoreData(tags: b)
        }
        print("Tags already in Core Data:", e.count)
        let f = b.filter { !e.contains($0) } //deletes 
        return f
    }
}
    
//MARK: - Extensions
//Remove duplicates
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

//Detect hashtags in text
extension String
{
    func hashtags() -> [String]
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

//Returns array of differences between 2 arrays
extension Array where Element: Hashable {
    func differenceArrays(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

//Adds element at specific position in list
extension Array {
    func chunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            let n = Swift.min(size, count - $0)
            return Array(self[$0 ..< $0 + n])
        }
    }
}

    

