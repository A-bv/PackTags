//
//  SmartTags+CoreDataProperties.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 06.08.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//
//

import Foundation
import CoreData


extension SmartTags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SmartTags> {
        return NSFetchRequest<SmartTags>(entityName: "SmartTags")
    }

    @NSManaged public var hashtagTitle: String?
    @NSManaged public var hashtagSearchDate: Date?

}

extension SmartTags : Identifiable {

}
