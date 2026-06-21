import Foundation
import CoreData

extension ThemeEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ThemeEntity> {
        return NSFetchRequest<ThemeEntity>(entityName: "ThemeCD")
    }

    @NSManaged var orderIndex: Int32
    @NSManaged var content: String?
    @NSManaged var image: Data?
    @NSManaged var name: String?
    @NSManaged var thumbnail: Data?
}
