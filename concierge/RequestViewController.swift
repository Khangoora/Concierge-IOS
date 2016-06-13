

import UIKit
import MapKit

class RequestViewController: CoreViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var placeMapView: MKMapView!
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    var proposal: Proposal!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Request"
        
        titleLabel.text = proposal.sportName
        timeLabel.text = proposal.timeDisplay
        timeLeftLabel.textColor = UIColor.redColor()
        
        timeLeftLabel.text = "Time left to accept: \(proposal.getTimeLeft())"
        
        setPlaceMap()
        
        container.layer.cornerRadius = 8
        acceptButton.backgroundColor = CoreViewController.primaryGreenColor
        rejectButton.backgroundColor = UIColor.alizarinColor()
        acceptButton.layer.cornerRadius = acceptButton.frame.size.width / 2
        rejectButton.layer.cornerRadius = rejectButton.frame.size.width / 2
        
        
    }
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        self.startLoading()
        
        let object = proposal.object
        object.setValue(true, forKey: "accepted")
        object.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            self.stopLoading()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setPlaceMap() {
        let location = CLLocation(latitude: proposal.location.latitude, longitude: proposal.location.longitude)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        placeMapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: proposal.location.latitude, longitude: proposal.location.longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = proposal.placeName
        annotation.subtitle = proposal.placeAddress
        placeMapView.addAnnotation(annotation)
        placeMapView.selectAnnotation(annotation, animated: true)
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func rejectTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
