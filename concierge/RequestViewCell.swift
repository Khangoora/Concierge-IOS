

import UIKit

class RequestViewCell: UITableViewCell {
    
    //proposalTitle
    @IBOutlet weak var proposalTitle: UILabel!
    //proposalAddress
    @IBOutlet weak var proposalAddress: UILabel!
    //proposalPlace
    @IBOutlet weak var proposalPlace: UILabel!
    //sportImage
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var timeLeft: UILabel!

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
