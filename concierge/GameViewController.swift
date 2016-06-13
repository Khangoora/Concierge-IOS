

import UIKit
import MapKit
import AddressBook

class GameViewController: CoreViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var playersView: UIView!
    
    @IBOutlet weak var trackButton: FUIButton!
    @IBOutlet weak var chatButton: FUIButton!
    @IBOutlet weak var playersImageContainer: UIView!
    @IBOutlet weak var placeMapView: MKMapView!
    
    @IBOutlet weak var playerImageOne: UIImageView!
    @IBOutlet weak var playerImageTwo: UIImageView!
    @IBOutlet weak var playerImageThree: UIImageView!
    
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var playerLabelOne: UILabel!
    @IBOutlet weak var playerLabelTwo: UILabel!
    @IBOutlet weak var playerLabelThree: UILabel!
    
    @IBOutlet weak var playerOnlineOne: UILabel!
    @IBOutlet weak var playerOnlineTwo: UILabel!
    @IBOutlet weak var playerOnlineThree: UILabel!
    
    @IBOutlet weak var navigateButton: FUIButton!
    
    @IBOutlet weak var lyftButton: FUIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!

    @IBOutlet weak var playerCount: UILabel!
    var game: Game!
    var players: [Player]! = []
    var maximumPlayers: Int!
    var isPresenting: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        maximumPlayers = Sport.getMaximum(game.sportName)

        uberButton.hidden = true
        
        titleLabel.text = game.sportName
        timeLabel.text = game.timeDisplay
        locationLabel.text = game.placeName
        
        trackButton.buttonColor = CoreViewController.primaryBlueColor
        trackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        trackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        chatButton.buttonColor = CoreViewController.primaryBlueColor
        chatButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        chatButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        navigateButton.buttonColor = CoreViewController.primaryBlueColor
        navigateButton.layer.cornerRadius = navigateButton.frame.size.width / 2
        navigateButton.clipsToBounds = true
        
        lyftButton.layer.cornerRadius = navigateButton.frame.size.width / 2
        lyftButton.clipsToBounds = true
        
        setBackgroundColors()
        setPlaceMap()
        setImageStyle(playerImageOne)
        setImageStyle(playerImageTwo)
        setImageStyle(playerImageThree)
        
        getPlayers(false, isTrack: false, isRate: false)
        
        playerCount.text = "\(game.minimum)/\(maximumPlayers)"
        
        hidePlayerLabels()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handlePlayersOnline", name: "onStatusChanged", object: nil)
        
        handlePlayersOnline()
        let locationCoordinate = CLLocationCoordinate2D(latitude: game.location.latitude, longitude: game.location.longitude)
        updateEta(locationCoordinate)
        
        if (!UIApplication.sharedApplication().canOpenURL(NSURL(string: "lyft://")!)) {
            lyftButton.hidden = true
        }
    }
    
    func handlePlayersOnline() {
        if (players.count == 0) {
            return
        }
        
        if (players.count > 0) {
            setViewAvailabilty(0, labelView: playerOnlineOne)
        }
        
        if (players.count > 1) {
            setViewAvailabilty(1, labelView: playerOnlineTwo)
        }
        
        if (players.count > 2) {
            setViewAvailabilty(2, labelView: playerOnlineThree)
        }
    }
    
    func setViewAvailabilty(index: Int, labelView: UILabel) {
        let player = players[index]
        if (userStatus[player.objectId] != nil) {
            let isOnline = userStatus[player.objectId]!
            labelView.textColor = isOnline ? UIColor.greenColor() : UIColor.redColor()
        }
    }
    
    func hidePlayerLabels() {
        playerLabelOne.hidden = true
        playerLabelTwo.hidden = true
        playerLabelThree.hidden = true
        
        playerOnlineOne.hidden = true
        playerOnlineTwo.hidden = true
        playerOnlineThree.hidden = true
        
        playerOnlineOne.textColor = UIColor.redColor()
        playerOnlineTwo.textColor = UIColor.redColor()
        playerOnlineThree.textColor = UIColor.redColor()
    }
    
    func setImageStyle(imageView: UIImageView) {
        imageView.hidden = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    func setBackgroundColors() {
        headerView.backgroundColor = CoreViewController.primaryGreenColor
        playersView.backgroundColor = UIColor.cloudsColor()
    }
    
    func setPlaceMap() {
        let location = CLLocation(latitude: game.location.latitude, longitude: game.location.longitude)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        placeMapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: game.location.latitude, longitude: game.location.longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = game.placeName
        annotation.subtitle = game.placeAddress
        placeMapView.addAnnotation(annotation)
        placeMapView.selectAnnotation(annotation, animated: true)
    }
    
    
    
    func getPlayers(isChat: Bool, isTrack: Bool, isRate: Bool) {
        startLoading()
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", containedIn: game.playerIds)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.stopLoading()
                self.players = Player.playersWithArray(objects!)
                
                if (isChat) {
                    self.performSegueWithIdentifier("showChat", sender: nil)
                } else if (isTrack) {
                    self.performSegueWithIdentifier("showTrack", sender: nil)
                } else if (isRate) {
                    self.performSegueWithIdentifier("showRating", sender: nil)
                } else {
                    self.setPlayers()
                    self.handlePlayersOnline()
                }
            } else {
                print("Failure")
            }
        }
    }
    
    func setPlayers() {
        if (players.count > 0) {
            playerImageOne.hidden = false
            playerLabelOne.hidden = false
            playerOnlineOne.hidden = false
            let playerOne = players[0]
            playerImageOne.setImageWithURL(NSURL(string: playerOne.profileImage))
            playerLabelOne.text = playerOne.firstName
        }
        
        if (players.count > 1) {
            playerImageTwo.hidden = false
            playerLabelTwo.hidden = false
            playerOnlineTwo.hidden = false
            let playerTwo = players[1]
            playerImageTwo.setImageWithURL(NSURL(string: playerTwo.profileImage))
            playerLabelTwo.text = playerTwo.firstName
        }
        
        if (players.count > 2) {
            playerImageThree.hidden = false
            playerLabelThree.hidden = false
            playerOnlineThree.hidden = false
            let playerThree = players[2]
            playerImageThree.setImageWithURL(NSURL(string: playerThree.profileImage))
            playerLabelThree.text = playerThree.firstName
        }
    }
    

    @IBAction func playersTapped(sender: AnyObject) {
        if (players.count > 0) {
            performSegueWithIdentifier("showPlayers", sender: nil)
        } else {
            getPlayers(false, isTrack: false, isRate: false)
        }
    }

    @IBAction func dismissTapped(sender: AnyObject) {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showChat") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationController = navigationController.childViewControllers.first as!
                ChatViewController
            destinationController.players = players
            destinationController.gameId = game.object.objectId!
        } else if (segue.identifier == "showTrack") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationController = navigationController.childViewControllers.first as! TrackViewController
            destinationController.players = players
            destinationController.game = game
        } else if (segue.identifier == "showRating") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationController = navigationController.childViewControllers.first as! RatingViewController
            destinationController.players = players
            destinationController.game = game
        } else if (segue.identifier == "showPlayerInfo") {
            let destinationController = segue.destinationViewController as! PlayerViewController
            destinationController.modalPresentationStyle = UIModalPresentationStyle.Custom
            destinationController.transitioningDelegate = self
            destinationController.player = sender as! Player
        }
    }

    @IBAction func chatTapped(sender: AnyObject) {
        if (players.count > 0) {
            performSegueWithIdentifier("showChat", sender: nil)
        } else {
            getPlayers(true, isTrack: false, isRate: false)
        }
    }
    
    @IBAction func trackTapped(sender: AnyObject) {
        if (players.count > 0) {
            performSegueWithIdentifier("showTrack", sender: nil)
        } else {
            getPlayers(false, isTrack: true, isRate: false)
        }
    }
    
    @IBAction func navigateTapped(sender: AnyObject) {
        let addressDictionary = [String(kABPersonAddressStreetKey): game.placeName]
        let locationCoordinate = CLLocationCoordinate2D(latitude: game.location.latitude, longitude: game.location.longitude)
        
        let placemark = MKPlacemark(coordinate: locationCoordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    
    
    @IBAction func uberTapped(sender: AnyObject) {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if (error == nil) {
                self.launchUber(geoPoint!)
            } else {
                print(error)
            }
        }
    }
    
    func launchUber(currentLocation: PFGeoPoint) {
        let dropOff = game.location
        var url: NSURL!
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!)) {
            url = NSURL(string: "uber://?client_id=DFwIh8gFnFNQjSJKtZ38NaHw5qXubeVt&action=setPickup&pickup[latitude]=\(currentLocation.latitude)&pickup[longitude]=\(currentLocation.longitude)&dropoff[latitude]=\(dropOff.latitude)&dropoff[longitude]=\(dropOff.longitude)")!
        } else {
            url = NSURL(string: "https://m.uber.com/?client_id=DFwIh8gFnFNQjSJKtZ38NaHw5qXubeVt&action=setPickup&pickup_latitude=\(currentLocation.latitude)&pickup_longitude=\(currentLocation.longitude)&dropoff_latitude=\(dropOff.latitude)&dropoff_longitude=\(dropOff.longitude)")!
        }
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    func launchLyft() {
        let url = NSURL(string: "lyft://")
        if (UIApplication.sharedApplication().canOpenURL(url!)) {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    @IBAction func lyftTapped(sender: AnyObject) {
        launchLyft()
    }
    
    @IBAction func titleTapped(sender: AnyObject) {
        if (players.count > 0) {
            performSegueWithIdentifier("showRating", sender: nil)
        } else {
            getPlayers(false, isTrack: false, isRate: true)
        }
    }
    
    func updateEta(destiantionCoordinate: CLLocationCoordinate2D) {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if (error == nil) {
                var playerCoordinate = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                var playerPlaceMark = MKPlacemark(coordinate: playerCoordinate, addressDictionary: nil)
                var playerItem = MKMapItem(placemark: playerPlaceMark)
                
                var destinationPlaceMark = MKPlacemark(coordinate: destiantionCoordinate, addressDictionary: nil)
                var destinationItem = MKMapItem(placemark: destinationPlaceMark)
                
                var directionsRequest = MKDirectionsRequest()
                directionsRequest.setSource = playerItem
                directionsRequest.setDestination = destinationItem
                directionsRequest.transportType = MKDirectionsTransportType.Any
                
                var directions = MKDirections(request: directionsRequest)
                directions.calculateETAWithCompletionHandler { (response: MKETAResponse!, error: NSError!) -> Void in
                    if (error == nil) {
                        var eta = self.getStringFromInterval(response.expectedTravelTime)
                        self.etaLabel.text = "ETA: \(eta)"
                    } else {
                        print("Getting eta was a failure")
                    }
                }
                
                var distanceRequest = MKDirections(request: directionsRequest)
                distanceRequest.calculateDirectionsWithCompletionHandler({ (response: MKDirectionsResponse!, error: NSError!) -> Void in
                    if (error == nil) {
                        var routeDetails = response.routes.last as! MKRoute
                        var distance = self.getStringFromDistance(routeDetails.distance)
                        self.distanceLabel.text = "Distance: \(distance) mi"
                    } else {
                        print("Failed getting here")
                    }
                })
            } else {
                print(error)
            }
        }
    }
    @IBAction func firstImageTapped(sender: AnyObject) {
        performSegueWithIdentifier("showPlayerInfo", sender: players[0])
    }
    
    @IBAction func secondImageTapped(sender: AnyObject) {
        performSegueWithIdentifier("showPlayerInfo", sender: players[1])
    }
    
    @IBAction func thirdImageTapped(sender: AnyObject) {
        performSegueWithIdentifier("showPlayerInfo", sender: players[2])
    }
    

    func getStringFromDistance(eta: CLLocationDistance) -> String {
        return String(format: "%.2f", arguments: [eta/1600])
    }
    
    func getStringFromInterval(eta: NSTimeInterval) -> String {
        let minutes = eta/60
        let minutesInt = Int(minutes)
        
        return "\(minutesInt) mins"
    }
    
    
}


extension GameViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        print("animating transition")
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if (isPresenting) {
            containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                toViewController.view.alpha = 1
                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true)
            }
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                fromViewController.view.alpha = 0
                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true)
                    fromViewController.view.removeFromSuperview()
            }
        }
    }
    
}
