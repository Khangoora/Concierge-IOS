

import UIKit

class ProposalProvider: NSObject {
    class var proposals: [Proposal] {
        let _proposals = [Proposal]()
        
//        var a = Proposal()
//        a.match = MatchProvider.matches[0]
//        a.playersIn = [a.match!.players![0]]
//        a.playersOut = [a.match!.players![1]]
        
        return _proposals
    }
}
