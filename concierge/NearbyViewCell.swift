

import UIKit

@objc protocol NearbyViewCellDelegate {
    optional func replySelected(gameSelected nearbyViewCell : NearbyViewCell)
}
class NearbyViewCell: UITableViewCell {
    
    //proposalTitle
    @IBOutlet weak var proposalTitle: UILabel!
    //proposalAddress
    @IBOutlet weak var proposalAddress: UILabel!
    //proposalPlace
    @IBOutlet weak var proposalPlace: UILabel!
    //sportImage
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    var game: Game!
    
    weak var delegate: NearbyViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        sportImage.layer.cornerRadius = sportImage.frame.size.width / 2
        sportImage.clipsToBounds = true
    }
    
    @IBAction func joinButtonTapped(sender: UIButton) {
        self.delegate?.replySelected!(gameSelected: self)
    }
}

