//
//  DataController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 21.10.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import CoreData
import Foundation

@MainActor
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "SmartTags")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
