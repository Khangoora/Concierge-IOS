

import UIKit

var availableSports: [Sport]?
class Sport: NSObject {
    var name: String?
    var object: PFObject!
    var minimum: Int!
    var maximum: Int!
    var searchQuery: String!
    var calories: Double!
    var workoutType: Int!
    
    init (gameObject: PFObject) {
        object = gameObject
        name = object.objectForKey("name") as? String
        minimum = object.objectForKey("minimum") as! Int
        maximum = object.objectForKey("maximum") as! Int
        searchQuery = object.objectForKey("search_query") as! String
        calories = object.objectForKey("calories") as! Double
        workoutType = object.objectForKey("workout_type") as! Int
    }
    
    class func gamesWithArray(array: [AnyObject]) -> [Sport] {
        var games = [Sport]()
        
        for dict in array as! [PFObject] {
            games.append(Sport(gameObject: dict))
        }
        
        return games
    }
    
    class func getWorkoutTypeForSport(sportName: String) -> Sport {
        for sport in availableSports! {
            if (sport.name == sportName) {
                return sport
            }
        }
        
        return availableSports![0]
    }
    
    class func getMaximum(sportName: String) -> Int! {
        for sport in availableSports! {
            if (sport.name == sportName) {
                return sport.maximum
            }
        }
        
        return 4
    }
    
    class func getSportImageName(sportName: String) -> String {
        if (sportName == "Gym") {
            return "gym"
        } else if (sportName == "Running") {
            return "running"
        } else if (sportName == "Biking") {
            return "cycling"
        } else if (sportName == "Basketball") {
            return "basketball"
        } else if (sportName == "Soccer") {
            return "soccer"
        } else if (sportName == "Tennis") {
            return "tennis"
        }
        
        
        return "misc"
    }
}
