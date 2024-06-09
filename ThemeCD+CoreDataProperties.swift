//
//  ThemeCD+CoreDataProperties.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
//

import Foundation
import CoreData

extension ThemeCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThemeCD> {
        return NSFetchRequest<ThemeCD>(entityName: "ThemeCD")
    }

    @NSManaged public var orderIndex: Int32
    @NSManaged public var content: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var name2: String?
    @NSManaged public var thumbnail: Data?
}
