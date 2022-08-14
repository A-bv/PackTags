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

    static func tagsAlreadyInCoreData (tags: [String]) -> [String] {
        
        guard !tags.isEmpty else { return [] }
        
        var tagsR = [String]()
        
        //condition for the predicate
        let regex = ".*(" + tags.map {
            NSRegularExpression.escapedPattern(for: $0)
        }.joined(separator: "|") + ")\\b.*"
        
        //build the predicate to prepare the filter for Core Data
        let predicate = NSPredicate(format: "content MATCHES %@", regex)
        
        //build the request
        let fetchRequest = NSFetchRequest<ThemeCD>(entityName: "ThemeCD")
        fetchRequest.predicate = predicate
        
        do  {
            let fetchedResult = try context.fetch(fetchRequest)
            for data in fetchedResult {
                
                let listOfTagsInFetchedObject = (data.value(forKey: "content")! as AnyObject).components(separatedBy: " ")
                
                let tagAlreadyInFetchedObject = Array(Set(listOfTagsInFetchedObject).intersection(Set(tags)))
                
                tagsR += tagAlreadyInFetchedObject
            }
        } catch {
            print(error.localizedDescription)
        }
        return tagsR
    }
}
