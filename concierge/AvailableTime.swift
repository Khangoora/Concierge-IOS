

import UIKit

var availableTimes: [AvailableTime]?
class AvailableTime: NSObject {
    
    var displayName: String!
    var object: PFObject!
    
    init(pfObject: PFObject) {
        object = pfObject
        displayName = object.objectForKey("display_str") as! String
    }
    
    class func timesWithArray(array: [AnyObject]) -> [AvailableTime] {
        var times = [AvailableTime]()
        
        for dict in array as! [PFObject] {
            times.append(AvailableTime(pfObject: dict))
        }
        
        return times
    }

}
