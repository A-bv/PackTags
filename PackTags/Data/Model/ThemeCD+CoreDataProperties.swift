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
    @NSManaged public var thumbnail: Data?
}
