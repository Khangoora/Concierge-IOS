

import UIKit

class Proposal: NSObject {
    var sportName: String!
    var placeName: String!
    var timeDisplay: String!
    var placeAddress: String!
    var createdAt: NSDate!
    var location: PFGeoPoint!
    var object: PFObject!
    
    init(proposalObject: PFObject) {
        object = proposalObject
        sportName = object.objectForKey("sportName") as! String
        placeName = object.objectForKey("placeName") as! String
        timeDisplay = object.objectForKey("timeDisplay") as! String
        placeAddress = object.objectForKey("placeAddress") as! String
        location = object.objectForKey("location") as! PFGeoPoint
        createdAt = object.createdAt!
    }
    
    func getTimeLeft() -> String {
        let currentDate = NSDate()
        let timeDifference = currentDate.timeIntervalSinceDate(self.createdAt)
        let timeInMinutes = 59 - Int(timeDifference/60)
        return "\(timeInMinutes)m"
    }
    
    class func proposalsWithArray(array: [AnyObject]) -> [Proposal] {
        var proposals = [Proposal]()
        
        for dict in array as! [PFObject] {
            proposals.append(Proposal(proposalObject: dict))
        }
        
        return proposals
    }
}
