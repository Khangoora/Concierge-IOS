

import UIKit

class ProposalCell: UITableViewCell {

    @IBOutlet weak var proposalTitle: UILabel!
    @IBOutlet weak var proposalAddress: UILabel!
    @IBOutlet weak var proposalPlace: UILabel!
    @IBOutlet weak var sportImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sportImage.layer.cornerRadius = sportImage.frame.size.width / 2
        sportImage.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
