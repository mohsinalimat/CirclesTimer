import Foundation
import CoreData

@objc(PomodoroData)
class PomodoroData: NSManagedObject {
    
    static internal let entityName = "PomodoroData"
    
    static func insertNewObjectIntoContext(_ objectContext: NSManagedObjectContext) -> PomodoroData {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: objectContext) as! PomodoroData
    }

}
