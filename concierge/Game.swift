

import UIKit

class Game: NSObject {
    var sportName: String!
    var placeName: String!
    var timeDisplay: String!
    var placeAddress: String!
    var location: PFGeoPoint!
    var players: [PFObject]!
    var playerIds: [String]! = []
    var object: PFObject!
    var minimum: Int!
    
    init(gameObject: PFObject) {
        object = gameObject
        sportName = object.objectForKey("sportName") as! String
        placeName = object.objectForKey("placeName") as! String
        timeDisplay = object.objectForKey("timeDisplay") as! String
        placeAddress = object.objectForKey("placeAddress") as! String
        players = object.objectForKey("players") as! [PFObject]!
        minimum = object.objectForKey("minimum") as! Int
        for player in players {
            playerIds.append(player.objectId!)
        }
        location = object.objectForKey("location") as! PFGeoPoint
    }
    
    class func gamesWithArray(array: [AnyObject]) -> [Game] {
        var games = [Game]()
        
        for dict in array as! [PFObject] {
            games.append(Game(gameObject: dict))
        }
        
        return games
    }

}
