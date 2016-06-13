

import UIKit
var newAvailability: NewAvailability!
class NewAvailability: NSObject {
    var sport: PFObject!
    var time: PFObject!
    var placeName: String!
    var placeAddress: String!
    var placeId: String!
    var minimum: Int!
    var sportName: String!
    var timeDisplay: String!
    var location: PFGeoPoint!
    var searchQuery: String!
}
