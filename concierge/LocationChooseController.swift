

import UIKit
import MapKit

class LocationChooseController: CoreViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var previewMapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    

    var places: [FTGooglePlacesAPISearchResultItem] = []
    var selectedPlace: FTGooglePlacesAPISearchResultItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.backgroundColor = CoreViewController.primaryBlueColor
        tableView.dataSource = self
        tableView.delegate = self
        
        submitButton.backgroundColor = CoreViewController.primaryGreenColor
        submitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        fetchLocations()
    }
    
    @IBAction func onFinishedTap(sender: UIButton) {
        
        let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationController = loginStoryboard.instantiateViewControllerWithIdentifier("FeedController") 
        
        self.presentViewController(destinationController, animated: true) { () -> Void in
            
        }
    }
    
    func fetchLocations() {
        startLoading()
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if (error == nil) {
                self.setMap(geoPoint!)
                self.fetchPlaces(geoPoint!.latitude, longitude: geoPoint!.longitude)
            } else {
                print(error)
            }
        }
    }
    
    func setMap(geoPoint: PFGeoPoint) {
        let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        previewMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func fetchPlaces(latitude: Double, longitude: Double) {
        let locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let request = FTGooglePlacesAPINearbySearchRequest(locationCoordinate: locationCoordinate)
        request.rankBy = FTGooglePlacesAPIRequestParamRankBy.Distance
        request.keyword = newAvailability.searchQuery
        request.radius = getRadius()
        FTGooglePlacesAPIService.executeSearchRequest(request, withCompletionHandler: { (response: FTGooglePlacesAPISearchResponse!, error: NSError!) -> Void in
            if (error == nil) {
                self.places = response.results as! [FTGooglePlacesAPISearchResultItem]
                self.tableView.reloadData()
            } else {
                print("Failure getting places")
            }
            self.stopLoading()
        })
    }
    
    func getRadius() -> UInt {
        if (PFUser.currentUser()!.valueForKey("radius") != nil) {
            return UInt(PFUser.currentUser()!.valueForKey("radius") as! Int)
        } else {
            return UInt(10)
        }
    }
}

extension LocationChooseController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.addressString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let place = places[indexPath.row]
        selectedPlace = place
        let location = CLLocation(latitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        previewMapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = place.name
        annotation.subtitle = place.addressString
        previewMapView.addAnnotation(annotation)
        previewMapView.selectAnnotation(annotation, animated: true)

    }
    
    @IBAction func submitTapped(sender: AnyObject) {
        if (selectedPlace == nil) {
            return;
        }
        
        let place = selectedPlace
        newAvailability.placeId = place.placeId!
        newAvailability.placeName = place.name!
        newAvailability.placeAddress = place.addressString!
        newAvailability.location = PFGeoPoint(latitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude)
        ApiClient.postAvailability()
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.popToRootViewControllerAnimated(true)
        let message = "We\'ve got your availability. You will be notified when there is a match."
        SweetAlert().showAlert("Thank you", subTitle: message, style: AlertStyle.Success, buttonTitle: "Ok", buttonColor: CoreViewController.primaryBlueColor)
    }
    @IBAction func dismissTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
}
