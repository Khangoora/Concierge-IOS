

import UIKit
import MapKit

class TrackViewController: CoreViewController, MKMapViewDelegate {
    
    var players: [Player]!
    var game: Game!
    var locationsRef: Firebase!

    @IBOutlet weak var playersMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceMap()
        setupFirebase()
        playersMapView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.hidden = true
    }
    
    func setupFirebase() {
        locationsRef = Firebase(url: "https://sportsconcierge.firebaseio.com/locations/")
        locationsRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            print("Child added")
            self.handleSnapshot(snapshot)
        })
        locationsRef.observeEventType(FEventType.ChildChanged, withBlock: { (snapshot) in
            print("Child changed")
            self.handleSnapshot(snapshot)
        })
        
    }
    
    func handleSnapshot(snapShot: FDataSnapshot) {
        for player in players {
            if (player.objectId == snapShot.key) {
                let lat = snapShot.value["lat"] as! Double
                let lng = snapShot.value["lng"] as! Double
                let name = snapShot.value["name"] as! String
                let locationCoord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                print("placed annotation success:  \(player.objectId)")
                placeAnnotation(locationCoord, name: name)
            }
        }
    }
    
    func getEtaFromPoints(playerCoordinate: CLLocationCoordinate2D, destiantionCoordinate: CLLocationCoordinate2D, annotation: MKPointAnnotation) {
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
                print(response.expectedTravelTime)
                annotation.subtitle = self.getStringFromInterval(response.expectedTravelTime)
            } else {
                print("Getting eta was a failure")
            }
        }
    }
    
    func getStringFromInterval(eta: NSTimeInterval) -> String {
        let minutes = eta/60
        let minutesInt = Int(minutes)
        
        return "\(minutesInt) mins away"
    }
    
    var locationCoordinate: CLLocationCoordinate2D!
    func setPlaceMap() {
        let location = CLLocation(latitude: game.location.latitude, longitude: game.location.longitude)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        playersMapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = PlayerPointAnnotation()
        locationCoordinate = CLLocationCoordinate2D(latitude: game.location.latitude, longitude: game.location.longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = game.placeName
        annotation.subtitle = game.placeAddress
        annotation.imageName = "flag"
        playersMapView.addAnnotation(annotation)
    }
    
    func placeAnnotation(coordinate: CLLocationCoordinate2D, name: String) {
        var replacedAnnotation = false
        for annotation in playersMapView.annotations as! [MKPointAnnotation] {
            if (annotation.title == name) {
                annotation.coordinate = coordinate
                getEtaFromPoints(coordinate, destiantionCoordinate: locationCoordinate, annotation: annotation)
                replacedAnnotation = true
            }
        }
        
        if (!replacedAnnotation) {
            let annotation = PlayerPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = name
            annotation.imageName = "marker"
            getEtaFromPoints(coordinate, destiantionCoordinate: locationCoordinate, annotation: annotation)
            playersMapView.addAnnotation(annotation)
        }
        
        playersMapView.showAnnotations(playersMapView.annotations, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if !(annotation is PlayerPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.canShowCallout = true
        }
        else {
            anView.annotation = annotation
        }
        
        let cpa = annotation as! PlayerPointAnnotation
        anView.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
