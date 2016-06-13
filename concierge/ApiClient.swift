
import UIKit

class ApiClient {
    class func registerPushNotification() {
        if let user = PFUser.currentUser() {
            let installation = PFInstallation.currentInstallation()
            installation.setObject(user, forKey: "user")
            installation.setObject(user.email!, forKey: "email")
            installation.saveInBackground()
        }
    }
    
    class func getAvailableTimes() {
        if let user = PFUser.currentUser() {
            let query = PFQuery(className: "Times")
            query.orderByAscending("start_time")
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if (error == nil) {
                    let times = AvailableTime.timesWithArray(objects!)
                    availableTimes = times
                    //TODO: Open endpoint to merge these queries.
                }
            })
        }
    }
    
    class func getQuestionBundle() {
        getAvailableTimes()
        getAvailableSports()
    }
    
    class func getAvailableSports() {
        if let user = PFUser.currentUser() {
            let query = PFQuery(className: "Sport")
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if (error == nil) {
                    let sports = Sport.gamesWithArray(objects!)
                    availableSports = sports
                    print("Second Checkpoint")
                }
            })
        }
    }
    
    class func postAvailability() {
        let newObject = PFObject(className: "Availability")
        newObject["sport"] = newAvailability.sport.objectId!
        newObject["time"] = newAvailability.time.objectId!
        newObject["placeName"] = newAvailability.placeName
        newObject["placeAddress"] = newAvailability.placeAddress
        newObject["placeId"] = newAvailability.placeId
        newObject["minimum"] = newAvailability.minimum
        newObject["sportName"] = newAvailability.sportName
        newObject["timeDisplay"] = newAvailability.timeDisplay
        newObject["location"] = newAvailability.location
        newObject["user"] = PFUser.currentUser()
        newObject["matched"] = false
        newObject.saveInBackground()
    }
}
