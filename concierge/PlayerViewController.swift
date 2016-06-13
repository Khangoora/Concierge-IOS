

import UIKit

class PlayerViewController: UIViewController {

    var player: Player!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        profileImage.setImageWithURL(NSURL(string: player.profileImage)!)
        nameLabel.text = "\(player.firstName) \(player.lastName)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
