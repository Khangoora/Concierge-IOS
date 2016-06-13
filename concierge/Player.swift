

import UIKit

class Player: NSObject {
    var firstName: String!
    var lastName: String!
    var id: String!
    var objectId: String!
    var profileImage: String!
    var avgRating: Float!
    var object: PFObject!
    
    init(playerObject: PFObject!) {
        object = playerObject
        firstName = object.objectForKey("first_name") as! String
        lastName = object.objectForKey("last_name") as! String
        id = object.objectForKey("facebook_id") as! String
        objectId = object.objectId!
        profileImage = object.objectForKey("image_url") as! String
        avgRating = object.objectForKey("avg_rating") as! Float
    }
    
    class func playersWithArray(array: [AnyObject]) -> [Player] {
        var players = [Player]()
        
        for dict in array as! [PFObject] {
            players.append(Player(playerObject: dict))
        }
        
        return players
    }
}
