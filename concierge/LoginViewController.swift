

import UIKit

class LoginViewController: CoreViewController, UIScrollViewDelegate {

    let backgroundColor = CoreViewController.primaryGreenColor
    let slides = [
        [ "image": "first_view.png", "text": "Tell us where, when and what you want to do!"],
        [ "image": "second_view.png", "text": "We will find someone with similar preferences and notify you!"],
        [ "image": "third_view.png", "text": "Meet people with common interests!"],
    ]
    let screen: CGRect = UIScreen.mainScreen().bounds
    var scroll: UIScrollView?
    var dots: UIPageControl?
    @IBOutlet weak var loginButton: FUIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        askForLocationPermission()
        
        loginButton.buttonColor = UIColor.whiteColor()
        loginButton.cornerRadius = 4.0
        loginButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Normal)
        loginButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Highlighted)
        
        view.backgroundColor = backgroundColor
        scroll = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: screen.width, height: screen.height * 0.9))
        scroll?.showsHorizontalScrollIndicator = false
        scroll?.showsVerticalScrollIndicator = false
        scroll?.pagingEnabled = true
        
        view.addSubview(scroll!)
        if (slides.count > 1) {
            dots = UIPageControl(frame: CGRect(x: 0.0, y: screen.height * 0.80, width: screen.width, height: screen.height * 0.05))
            dots?.numberOfPages = slides.count
            view.addSubview(dots!)
        }
        for var i = 0; i < slides.count; ++i {
            if let image = UIImage(named: slides[i]["image"]!) {
                let imageView: UIImageView = UIImageView(frame: getFrame(image.size.width, iH: image.size.height, slide: i, offset: screen.height * 0.15))
                imageView.image = image
                scroll?.addSubview(imageView)
            }
            if let text = slides[i]["text"] {
                let textView = UITextView(frame: CGRect(x: screen.width * 0.1 + CGFloat(i) * screen.width, y: screen.height * 0.68, width: screen.width * 0.75, height: 100.0))
                textView.text = text
                textView.editable = false
                textView.selectable = false
                textView.textAlignment = NSTextAlignment.Center
                textView.font = UIFont.systemFontOfSize(UIFont.labelFontSize(), weight: 0)
                textView.textColor = UIColor.whiteColor()
                textView.backgroundColor = UIColor.clearColor()
                scroll?.addSubview(textView)
            }
        }
        scroll?.contentSize = CGSizeMake(CGFloat(Int(screen.width) *  slides.count), screen.height * 0.5)
        scroll?.delegate = self
        dots?.addTarget(self, action: Selector("swipe:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func getFrame (iW: CGFloat, iH: CGFloat, slide: Int, offset: CGFloat) -> CGRect {
        let mH: CGFloat = screen.height * 0.50
        let mW: CGFloat = screen.width
        var h: CGFloat
        var w: CGFloat
        let r = iW / iH
        if (r <= 1) {
            h = min(mH, iH)
            w = h * r
        } else {
            w = min(mW, iW)
            h = w / r
        }
        return CGRectMake(
            max(0, (mW - w) / 2) + CGFloat(slide) * screen.width,
            max(0, (mH - h) / 2) + offset,
            w,
            h
        )
    }
    
    
    func swipe(sender: AnyObject) -> () {
        if let scrollView = scroll {
            let x = CGFloat(dots!.currentPage) * scrollView.frame.size.width
            scroll?.setContentOffset(CGPointMake(x, 0), animated: true)
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) -> () {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        dots!.currentPage = Int(pageNumber)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    func loginWithFacebook() {
        startLoading()
        let permissionsArray = ["public_profile", "email", "user_friends"];
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray, block: { (user: PFUser?, error: NSError?) -> Void in
            if (error == nil) {
                self.getFacebookDetails()
            } else {
                self.stopLoading()
                print("error")
            }
        })
    }
    
    func getFacebookDetails() {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        request.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, response: AnyObject!, error: NSError!) -> Void in
            if (error == nil) {
                let firstName = response["first_name"] as? String
                let lastName = response["last_name"] as? String
                let id = response["id"] as? String
                let email = response["email"] as? String
                let imageUrl = "https://graph.facebook.com/\(id!)/picture?type=large&return_ssl_resources=1"
                let gender = response["gender"] as? String
                self.saveUserProperties(id, firstName: firstName, lastName: lastName, email: email, imageUrl: imageUrl, gender: gender)
            } else {
                self.stopLoading()
                print("Failure getting details")
            }
        }
    }
    
    let manager = CLLocationManager()
    func askForLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "Please enable location to see bros around you.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func saveUserProperties(id: String?, firstName: String?, lastName: String?, email: String?, imageUrl: String?, gender: String?) {
        var dictionary = [String: String]()
        dictionary["facebook_id"] = id!
        dictionary["first_name"] = firstName != nil ? firstName! : ""
        dictionary["last_name"] = lastName != nil ? lastName! : ""
        dictionary["email"] = email != nil ? email! : ""
        dictionary["image_url"] = imageUrl != nil ? imageUrl : ""
        dictionary["gender"] = gender != nil ? gender : ""
        PFUser.currentUser()?.setValuesForKeysWithDictionary(dictionary)
        PFUser.currentUser()?.setValue(5.0, forKey: "avg_rating")
        PFUser.currentUser()?.saveInBackground()
        ApiClient.registerPushNotification()
        self.stopLoading()
        performSegueWithIdentifier("loggedInSegue", sender: nil)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        loginWithFacebook()
    }

}
