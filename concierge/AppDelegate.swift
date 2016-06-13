

import UIKit

var userStatus: [String:Bool] = [:]
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var locationTask: NSTimer!
    var appBackgrounded = false
    var locationsRef: Firebase!
    var presenceRef: Firebase!
    var name: String!
    var objectId: String!
    
    func updateLocation() {
        if (PFUser.currentUser() == nil || !PFUser.currentUser()!.isAuthenticated()) {
            stopTimer()
            return
        }
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if (error == nil) {
                let values = ["name": self.name, "lat": geoPoint!.latitude, "lng": geoPoint!.longitude]
                self.locationsRef.childByAppendingPath(self.objectId).setValue(values)
            } else {
                print("Sending error is failing")
                print(error)
            }
        }
    }
    
    func handlePresence() {
        presenceRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            userStatus[snapshot.key] = snapshot.value["status"] as! Bool
            NSNotificationCenter.defaultCenter().postNotificationName("onStatusChanged", object: nil)
        })
        presenceRef.observeEventType(FEventType.ChildChanged, withBlock: { (snapshot) in
            userStatus[snapshot.key] = snapshot.value["status"] as! Bool
            NSNotificationCenter.defaultCenter().postNotificationName("onStatusChanged", object: nil)
        })
    }
    
    func startTimer() {
        if (locationTask == nil || !locationTask.valid) {
            let firstName = PFUser.currentUser()!.valueForKey("first_name") as! String
            let lastName = PFUser.currentUser()!.valueForKey("last_name") as! String
            objectId = PFUser.currentUser()!.objectId!
            name = "\(firstName) \(lastName)"

            locationTask = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        name = nil
        if (locationTask != nil && locationTask.valid) {
            locationTask.invalidate()
            locationTask = nil
        }
    }
    
    func startTrackingUserLocation() {
        let onlineValues = ["status": true]
        let offlineValues = ["status": false]
        presenceRef.childByAppendingPath(PFUser.currentUser()!.objectId!).setValue(onlineValues)
        presenceRef.childByAppendingPath(PFUser.currentUser()!.objectId!).onDisconnectSetValue(offlineValues)
        startTimer()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationsRef = Firebase(url: "https://sportsconcierge.firebaseio.com/locations/")
        presenceRef = Firebase(url: "https://sportsconcierge.firebaseio.com/presence/")
        handlePresence()
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("wS9b0MnBZTPwPxdWaACBafwfYJcRW0FYPgVseIVE",
            clientKey: "vSwDQG2ifTD7LvCOnu8yM9XeF07Y23zdoEHnAC39")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        FTGooglePlacesAPIService.provideAPIKey("AIzaSyAtMudiBgeq-zwTQRPpGbI5Q6oUaSvxLLI")
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startTrackingUserLocation", name: "startTrackingUserLocation", object: nil)
        
        if (PFUser.currentUser() != nil && PFUser.currentUser()!.isAuthenticated()) {
            let navigationController = storyBoard.instantiateViewControllerWithIdentifier("feedTabBarController") as! UITabBarController
            window?.rootViewController = navigationController
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Got here")
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("global", forKey: "channels")
        installation.saveInBackground()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        if (locationTask != nil && locationTask.valid) {
            appBackgrounded = true
        }
        stopTimer()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        if (appBackgrounded) {
            startTimer()
            appBackgrounded = false
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


}

