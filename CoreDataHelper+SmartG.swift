//
//  CoreDataHelper+SmartG.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.08.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Smart Hashtags
extension CoreDataHelper {
    static func newTag() -> SmartTags {
        let tag = NSEntityDescription.insertNewObject(
            forEntityName: "SmartTags",
            into: context) as! SmartTags
        return tag
    }
    
    static func saveTag() {
        do {
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteTag(theme: SmartTags) {
        context.delete(theme)
        saveTag()
    }

    static func retrieveTags() -> [SmartTags] {
        do {
            let fetchRequest = NSFetchRequest<SmartTags>(entityName: "SmartTags")
            
            let results = try context.fetch(fetchRequest)

            return results
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
}
