

import UIKit

class ProfileViewController: CoreViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    
    
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var authorizeButton: FUIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logoutButton: FUIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewStyles()
        setData()
    }
    
    func setViewStyles() {
        
        logoutButton.buttonColor = CoreViewController.primaryGreenColor
        logoutButton.cornerRadius = 4.0
        logoutButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        logoutButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        authorizeButton.buttonColor = CoreViewController.primaryGreenColor
        authorizeButton.cornerRadius = 4.0
        authorizeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        authorizeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        distanceSlider.configureFlatSliderWithTrackColor(UIColor.silverColor(), progressColor: UIColor.belizeHoleColor(), thumbColor: UIColor.peterRiverColor())
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }
    
    func setData() {
        let profileUrl = PFUser.currentUser()?.valueForKey("image_url") as! String
        let firstName = PFUser.currentUser()?.valueForKey("first_name") as! String
        let lastName = PFUser.currentUser()?.valueForKey("last_name") as! String
        let rating = PFUser.currentUser()?.valueForKey("avg_rating") as? Float
        let email = PFUser.currentUser()?.email!
        let distance = getDistance()
        print(profileUrl)
        distanceSlider.value = distance
        distanceLabel.text = "\(Int(distance)) mi"
        profileImage.setImageWithURL(NSURL(string: profileUrl))
        nameLabel.text = "\(firstName) \(lastName)"
        emailLabel.text = email
        if (rating != nil) {
            ratingLabel.text = getRating(Int(rating!))
        } else {
            ratingLabel.text = getRating(5)
        }
    }
    
    func getRating(rating: Int) -> String {
        var output = ""
        
        for(var i = 0; i < rating; i++) {
            output += "★"
        }
        return output
    }
    
    @IBAction func dismissProfileController(sender: AnyObject) {
        PFUser.currentUser()?.setValue(distanceSlider.value, forKey: "radius")
        PFUser.currentUser()?.save()
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }

    @IBAction func logoutTapped(sender: AnyObject) {
        PFUser.logOut()
        performSegueWithIdentifier("loggedOut", sender: nil)
//        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func distanceChanged(sender: AnyObject) {
        let distance = Int(distanceSlider.value)
        distanceLabel.text = "\(distance) mi"
        print("distance value is \(distance)")
    }
    
    func getDistance() -> Float {
        if (PFUser.currentUser() != nil && PFUser.currentUser()!.valueForKey("radius") != nil) {
            return PFUser.currentUser()!.valueForKey("radius") as! Float
        } else {
            return 10.0
        }
    }

    @IBAction func authorizeHealthKitTapped(sender: AnyObject) {
        authorizeHealthKit()
    }
    
    let healthManager:HealthManager = HealthManager()
    func authorizeHealthKit() {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("Success authorizing healthKit")
            }
            else
            {
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
}
