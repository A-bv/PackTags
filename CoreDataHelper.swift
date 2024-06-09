//
//  CoreDataHelper.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }

        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        return context
    }()
}

// MARK: - Themes

// Base
extension CoreDataHelper {
    static func newTheme() -> ThemeCD {
        let theme = NSEntityDescription.insertNewObject(
            forEntityName: "ThemeCD",
            into: context) as! ThemeCD
        return theme
    }
    
    static func saveTheme() {
        do {
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func delete(theme: ThemeCD) {
        context.delete(theme)
        saveTheme()
    }

    static func retrieveThemes() -> [ThemeCD] {
        do {
            let fetchRequest = NSFetchRequest<ThemeCD>(entityName: "ThemeCD")
            
            //OPTIONAL: Reorder tableView
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
            
            let results = try context.fetch(fetchRequest)

            return results
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")

            return []
        }
    }
}

extension CoreDataHelper {
    static func getRecordsCount() -> Int32 {
        let fetchRequest = NSFetchRequest<ThemeCD>(entityName: "ThemeCD")
        do {
            let count = try CoreDataHelper.context.count(for: fetchRequest)
            return Int32(count)
        } catch {
            print(error.localizedDescription)
        }
        return Int32(0)
    }
    
    static func tagsAlreadyInCoreData(tags: [String]) -> [String] {
        guard !tags.isEmpty else { return [] }
        
        // Create a regex pattern to match any of the tags
        let regex = tags.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let predicate = NSPredicate(format: "content MATCHES %@", ".*(\(regex))\\b.*")
        
        // Prepare the fetch request
        let fetchRequest = NSFetchRequest<ThemeCD>(entityName: "ThemeCD")
        fetchRequest.predicate = predicate
        
        var matchedTags = [String]()
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            for result in fetchedResults {
                if let content = result.value(forKey: "content") as? String {
                    let contentTags = Set(content.components(separatedBy: " "))
                    matchedTags.append(contentsOf: contentTags.intersection(tags))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return Array(Set(matchedTags))
    }
}
