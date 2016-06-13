

import UIKit

class MatchProvider: NSObject {
    class var matches: [Match] {
        var _matches = [Match]()
        
        let a = Match()
//        a.game = GameProvider.games[0];
//        a.players = PlayerProvider.listWith(a.game?.players!)
        a.date = NSDate()
        a.location = "16th and Mission"
        _matches.append(a)
        
        return _matches
    }
}
