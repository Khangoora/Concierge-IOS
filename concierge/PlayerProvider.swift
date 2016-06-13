

import UIKit

class PlayerProvider: NSObject {
    class var players: [Player] {
        var _players = [Player]()
        
        var justin = Player()
        justin.firstName = "Jaskirat"
        justin.lastName = "Khangoora"
        justin.id = "123412341234"
        justin.reliability = 0.86
        _players.append(justin)
        
        var praveen = Player()
        praveen.firstName = "Praveen"
        praveen.lastName = "Chekuri"
        praveen.id = "9823409823"
        praveen.reliability = 0.95
        _players.append(praveen)
        
        var ben = Player()
        ben.firstName = "Ben"
        ben.lastName = "Sandofsky"
        ben.id = "33223"
        ben.reliability = 0.76
        _players.append(ben)
        
        var francesco = Player()
        francesco.firstName = "Francesco"
        francesco.lastName = "De la Pena"
        francesco.id = "3888s882882"
        francesco.reliability = 0.99
        _players.append(francesco)
        
        var barack = Player()
        barack.firstName = "Barack"
        barack.lastName = "Obama"
        barack.id = "93939393"
        barack.reliability = 0.93
        _players.append(barack)
        
        return _players
    }
    
    class func listWith(number: Int) -> [Player] {

        var roster = [Player]()
        
        for index in 0...number {
            if roster.count < index {
                roster.append(self.players[index])
            } else {
                roster.append(self.players.last!)
            }
        }
        
        return roster
    }
}
