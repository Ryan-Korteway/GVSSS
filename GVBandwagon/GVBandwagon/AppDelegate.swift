//
//  AppDelegate.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//


// APP DELEGATE NEEDS TO HOLD COPY OF THE ACTIVE DRIVE AND RIDE VIEW CONTROLLERS SO THAT THEY CAN BE 
// RETRIEVED AND USED TO MAKE PIN REQUESTS ETC WITHOUT THE MAPS BEING THE ONES ON SCREEN!!! could be furuther improved by init'ing them to UIViewcontrollers and then they only get reassigned to be used if the user ever opens up the driver controller etc.

import UIKit
import Firebase
import GoogleSignIn
import Google
import GoogleMaps
import KGFloatingDrawer
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Go to func prepareDrawerViewController() to set initial views //

    var window: UIWindow?
    
    var timer = Timer()
    
    var status = "request";
    var mode = "rider";
    var offeredID = "none"; //the id of the offered rider, to be set when we offer a ride to someone.
    
    var locationManager = CLLocationManager()
    
    var ourlat : CLLocationDegrees = 0.0
    var ourlong : CLLocationDegrees = 0.0
    
    let kKGDrawersStoryboardName = "Main"
    
    let rideNavControllerStoryboardId = "rideNavController"
    let rideViewControllerStoryboardId = "rideViewControllerStoryboardId"
    let driveViewControllerStoryboardId = "driveViewControllerStoryboardId"
    let menuTableViewControllerStoryboardId = "menuViewControllerStoryboardId"
    let signInViewControllerStoryboardId = "signInViewControllerStoryboardId"
    let settingsNavControllerStoryboardId = "settingsNavigationController"
    let driveTabBarControllerStoryboardId = "driveTabBarController"
    let driverPanelViewControllerStoryboardId = "driverPanelViewController"
    let helpViewControllerStoryboardId = "helpViewController"
    let myHistoryNavigationControllerStoryboardId = "myHistoryNavigationController"
    let scheduledRidesNavigationControllerStoryboardId = "scheduledRidesNavigationController"
    
    let kKGDrawerSettingsViewControllerStoryboardId = "KGDrawerSettingsViewControllerStoryboardId"
    let kKGDrawerWebViewViewControllerStoryboardId = "KGDrawerWebViewControllerStoryboardId"
    let kKGLeftDrawerStoryboardId = "KGLeftDrawerViewControllerStoryboardId"
    let kKGRightDrawerStoryboardId = "KGRightDrawerViewControllerStoryboardId"
    
    let center = UNUserNotificationCenter.current()
    
    let options: UNAuthorizationOptions = [.alert, .sound];
    
    let offerAction = UNNotificationAction(identifier: "offer",
                                           title: "offer ride", options: [])
    
    let dismissAction = UNNotificationAction(identifier: "dismiss",
                                             title: "dismiss notification", options: [.destructive])
    
    let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept offer", options: []) //open the app to the ride details page or leave it be?
    
    
    var categoryOffer: UNNotificationCategory
    
    var categoryAccept: UNNotificationCategory
    
    let categoryNothing: UNNotificationCategory = UNNotificationCategory(identifier: "nothing_category", actions: [], intentIdentifiers: [], options: [])
    
    
    //the arrays of favorite and disfavored riders/drivers for a given user.
    var riderWhiteList: NSArray = []
    var riderBlackList: NSArray = []
    var driverWhiteList: NSArray = []
    var driverBlackList: NSArray = []
    var acceptsToWatch: NSArray = []
    var lastState = "rider"
    
    var driverVenmoID = "none" //the drivers venmo ID to be updated etc.
    
    var firstViewController = UIViewController()
    var firstSet = false
    var DriveViewController_AD = UIViewController()
    var DriveSet = false
    
    // Overriding init() and putting FIRApp.configure() here to ensure it's configured before
    // the first view controller tries to retreive a reference to it.
    override init() {
        
        categoryOffer = UNNotificationCategory(identifier: "offer_category", actions: [offerAction,dismissAction],
                                               intentIdentifiers: [], options: [])
        
        categoryAccept = UNNotificationCategory(identifier: "accept_category", actions: [ acceptAction, dismissAction],
                                                intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([categoryAccept, categoryOffer, categoryNothing])

        super.init()
        
        print("configuring FIRApp")
        FIRApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
        
        // Moved to didFinish... below
        //GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyCGT0W7GBgr5dWY0E60RvwZatwKmTDT7u8")
        //For google places: GMSPlacesClient.provideAPIKey("AIzaSyCGT0W7GBgr5dWY0E60RvwZatwKmTDT7u8")
        
        // Make sign in the root view controller UNLESS they are already signed in.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // If user is not signed in...
        let signInVC = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
        window?.rootViewController = signInVC
        
        // If user IS signed in...
        //window?.rootViewController = drawerViewController
        // OR
        // self.initiateDrawer()
        
        window?.makeKeyAndVisible()
    
        print("finished launching with options")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        let lastView = self._centerViewController //neeeds to be moved to
        //custom coding class and use KG's floating drawers and references instead of this whole floating drawers things.
        
        switch(lastView) { //bad switch statement?
        case is FirstViewController:
            lastState = "rider"
        case is DriveViewController:
            lastState = "driver"
            //make case for each view controller that could be on each screen and make each of the view controllers follow each of the protocols.
        default:
            print("something went wrong in lastView set up switch.")
        }

        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if(FIRAuth.auth()!.currentUser != nil) {
            let ref = FIRDatabase.database().reference();
            let userID = FIRAuth.auth()!.currentUser!.uid;
            
            ref.child("users/\(userID)/rider/offers/immediate").removeAllObservers(); //might need to add an extra observer remover for the path of offers/immediate/buffer
            
            ref.child("requests/immediate").removeAllObservers();
            
            self.setUpClosedObservers();
            
            for item in acceptsToWatch {
                self.closedRideAccept(toWatchUid: item as! String);
            }
        }

        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if(FIRAuth.auth()!.currentUser != nil) {
            self.setUpOpenObservers();
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if(FIRAuth.auth()!.currentUser == nil) { //use a guard and uid is string otherwise dont run, like sign in.
            return
        } else {
            
            let userID = FIRAuth.auth()!.currentUser!.uid
            
            let ref = FIRDatabase.database().reference()
            
            ref.child("users/\(userID)/rider/offers/immediate").removeAllObservers(); //might need to add an extra observer remover for the path of offers/immediate/buffer
            
            ref.child("requests/immediate").removeAllObservers();
            
            ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(snapshot.value! as! Bool) {
                    let tempRef = ref.child("activedrivers/\(userID)/")
                    tempRef.child("jointime").removeValue()
                    tempRef.child("location").removeValue()
                }
                
            })
        }
        
        timer.invalidate();
        
    }
    
    // Added
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    // Added for iOS 8 and older users
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    private var _drawerViewController: KGDrawerViewController?
    var drawerViewController: KGDrawerViewController {
        get {
            if let viewController = _drawerViewController {
                return viewController
            }
            return prepareDrawerViewController()
        }
    }
    
    // Set our own view controllers here:
    func prepareDrawerViewController() -> KGDrawerViewController {
        //let drawerViewController = KGDrawerViewController()
        let drawerViewController = CustomKGDrawerViewController()
        
        //drawerViewController.centerViewController = drawerSettingsViewController()
        //drawerViewController.leftViewController = leftViewController()
        
        // Set our initial view controllers here for menu and center:
        drawerViewController.centerViewController = rideViewController()
        drawerViewController.leftViewController = menuTableViewController()
        
        // Right drawer is for the driver's panel only
        drawerViewController.rightViewController = driverPanelViewController()
        drawerViewController.backgroundImage = UIImage(named: "bkgd")
        
        _drawerViewController = drawerViewController
        
        return drawerViewController
    }
    
    private func drawerStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: kKGDrawersStoryboardName, bundle: nil)
        return storyboard
    }
    
    private func viewControllerForStoryboardId(storyboardId: String) -> UIViewController {
        let viewController: UIViewController = drawerStoryboard().instantiateViewController(withIdentifier: storyboardId)
        return viewController
    }
    
    // -------------------
    func drawerSettingsViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: kKGDrawerSettingsViewControllerStoryboardId)
        return viewController
    }
    
    func rideViewController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: rideNavControllerStoryboardId)
        return viewController as! UINavigationController
    }
    
    func driveViewController() -> UITabBarController {
        let viewController = viewControllerForStoryboardId(storyboardId: driveTabBarControllerStoryboardId)
        return viewController as! UITabBarController
    }
    
    func settingsNavController() -> UINavigationController {
        let navController = viewControllerForStoryboardId(storyboardId: settingsNavControllerStoryboardId)
        return navController as! UINavigationController
    }
    
    func menuTableViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: menuTableViewControllerStoryboardId)
        return viewController
    }
    
    func driverPanelViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: driverPanelViewControllerStoryboardId)
        return viewController
    }
    
    func signInViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
        return viewController
    }
    
    func scheduledRidesTableViewController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: scheduledRidesNavigationControllerStoryboardId)
        return viewController as! UINavigationController
    }
    
    func myHistoryTableViewController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: myHistoryNavigationControllerStoryboardId)
        return viewController as! UINavigationController
    }
    
    func helpViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: helpViewControllerStoryboardId)
        return viewController
    }
    
    
    // -------------------
    
    private func leftViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: kKGLeftDrawerStoryboardId)
        return viewController
    }
    
    private func rightViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: kKGRightDrawerStoryboardId)
        return viewController
    }
    
    func toggleLeftDrawer(sender:AnyObject, animated:Bool) {
        _drawerViewController?.toggleDrawer(.left, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
    }
    
    func toggleRightDrawer(sender:AnyObject, animated:Bool) {
        _drawerViewController?.toggleDrawer(.right, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
    }
    
    private var _centerViewController: UIViewController?
    var centerViewController: UIViewController {
        get {
            if let viewController = _centerViewController {
                return viewController
            }
            return drawerSettingsViewController()
        }
        set {
            if let drawerViewController = _drawerViewController {
                drawerViewController.closeDrawer(drawerViewController.currentlyOpenedSide, animated: true) { finished in }
                if drawerViewController.centerViewController != newValue {
                    drawerViewController.centerViewController = newValue
                }
            }
            _centerViewController = newValue
        }
    }
    
    func firebaseSignOut() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth!.signOut()
            print("Successfully signed out user.")
            //performSegue(withIdentifier: "signOutSegue", sender: self)
            let signInVC = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
            window?.rootViewController = signInVC
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func initiateDrawer() {
        window?.rootViewController = drawerViewController
    }
    
    //RYAN'S ADDITIONS TO APP DELEGATE TO GET READY FOR THE LISTS OF REQUESTS AND OFFERS AND THE
    //NOTIFICATIONS/VIEWS UPDATING THAT THEY WILL CAUSE
    
    //the method to call during app did launch or app did enter foreground.
    //terminate should destroy all the open observers
    func setUpOpenObservers() {                         //observer set up should happen AFTER SIGN IN!!! so put it into the success part of the google sign in button logic.
        
        //need to watch out for the observers stopping the lat long updates from occuring...
        
        let ref = FIRDatabase.database().reference();
        let userID = FIRAuth.auth()!.currentUser!.uid;
        
        //get black and whitelist too.
        
        ref.child("users/\(userID)/rider/whiteList").observeSingleEvent(of: .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.riderWhiteList = localList;
        })
        
        ref.child("users/\(userID)/rider/blackList").observeSingleEvent(of: .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.riderBlackList = localList;
        })
        
        ref.child("users/\(userID)/driver/whiteList").observeSingleEvent(of: .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.driverWhiteList = localList;
        })
        
        ref.child("users/\(userID)/driver/blackList").observeSingleEvent(of: .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding( (wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.driverBlackList = localList;
        })
        
        ref.child("users/\(userID)/driver/venmoID").observeSingleEvent(of: .value, with: { snapshot in
        
            for local in snapshot.children { //grab venmo id.
                self.driverVenmoID = (local as AnyObject).value;
            }
        })
        
        //watching for ride offers, and whitelist ride requests. BIG NOTE HERE ride acceptances will have to be watched for elsewhere/later when we know the uid that we will need to watch.
        ref.child("users/\(userID)/rider/offers/immediate").observe( .childAdded, with: { snapshot in
            //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
            
            //and again need switch for casting etc.
            
            if(snapshot.value is NSNull) {
                print("snapshot null, doing nothing");
            } else {
                // is lastView stupid/irrelephant?
                
                if(!self.firstSet) {
                    print("first view controller not set up yet")
                    
                    let vc = self.centerViewController as! UITabBarController
                    (vc.childViewControllers[0].childViewControllers[0] as! DriveViewController).ride_request(item: cellItem.init(snapshot: snapshot as FIRDataSnapshot))
                } else{
                        print("default")
                }
            
            }
        })
        
    }
    
    // entering background should make observers that make local notifications, versus calling the appropriate notification/data updating methods in the currently open view controller.
    func setUpClosedObservers() {
        //watching for ride offers and white list ride requests here to trigger local notifications.
        let ref = FIRDatabase.database().reference();
        let userID = FIRAuth.auth()!.currentUser!.uid;
        
        if(lastState == "rider") {
            ref.child("users/\(userID)/rider/offers/immediate").observe( .childAdded, with: { snapshot in
                
                let localCell = cellItem.init(snapshot: snapshot)
                
                let content = UNMutableNotificationContent()
                content.title = "New Driver Offer"
                content.body = "Would you like to accept \(localCell.name)'s offer?"
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "accept_category"
                content.userInfo = localCell.toAnyObject() as! [AnyHashable : Any] //compiler forced the conversion.
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let identifier = "Driver Offer"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: { (error) in
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                    }
                })
                
            })
            
        } else {
            
            ref.child("requests/immediate").observe( .childAdded, with: { snapshot in
                //local notification for requests from white listed drivers.
                
                //only interests you if it is a request from someone in your whitelist.
                
                print(self.driverWhiteList.contains(snapshot.key as NSString))
                
                if(self.driverWhiteList.contains((snapshot.key as NSString))) {
                    //trigger local notification here.
                    let localCell = cellItem.init(snapshot: snapshot)
                    
                    let content = UNMutableNotificationContent()
                    content.title = "New White list Rider Request"
                    content.body = "Would you like to give \(localCell.name) a ride?"
                    content.sound = UNNotificationSound.default()
                    content.categoryIdentifier = "offer_category"
                    content.userInfo = localCell.toAnyObject() as! [AnyHashable : Any] //compiler forced the conversion.
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    let identifier = "Rider Request"
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: { (error) in
                        
                        if let error = error {
                            
                            print(error.localizedDescription)
                        }
                    })
                    
                }
            })
        }
    }
    
    func openRideAccept(toWatchUid: String) {
        //give rider/offers/immediate a /buffer/ so the buffer can be removed and thus the snapshot is returned with the accepted driver value updated the rests false with turn downs.
        
        let ref = FIRDatabase.database().reference();
        
        ref.child("users/\(toWatchUid)/rider/offers/immediate").observeSingleEvent(of: .childRemoved, with: { snapshot in
            //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
            
            if(!self.DriveSet) {
                print("driver class not set")
            } else {
                    (self.DriveViewController_AD as! DriveViewController).ride_accept(item: cellItem.init(snapshot: snapshot as FIRDataSnapshot));
            }
            
        })
        
        acceptsToWatch = acceptsToWatch.adding(toWatchUid) as NSArray;
    }
    
    func closedRideAccept(toWatchUid: String) {
        
        let ref = FIRDatabase.database().reference();
        
        ref.child("users/\(toWatchUid)/rider/offers/immediate").observeSingleEvent(of: .childRemoved, with: { snapshot in
            let localCell = cellItem.init(snapshot: snapshot)
            
            let content = UNMutableNotificationContent()
            content.title = "Ride Offer Response"
            
            if(localCell.accepted == 1) {
                content.body = "Your ride offer has been accepted."
            } else {
                content.body = "We are sorry but your ride offer was declined" //need wording help here.
            }
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "nothing_category"
            content.userInfo = localCell.toAnyObject() as! [AnyHashable : Any] //compiler forced the conversion.
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let identifier = "ride acceptance"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            self.center.add(request, withCompletionHandler: { (error) in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                }
            })
            
        })
    }
    
    func startTimer() {
        
        let ref = FIRDatabase.database().reference();
        let ourID = FIRAuth.auth()!.currentUser!.uid;
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 10 //might need to slow this down here.
            locationManager.startUpdatingLocation()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: {_ in
        
        //still need working lat long.
            print("timer firing");
            
            if(self.status == "request") {
                
                if(self.mode == "rider") {
                    ref.child("requests/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong]);
                } else {
                    ref.child("activedrivers/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong]);
                }
                
            } else if (self.status == "offer") {
                
                if(self.mode == "rider") {
                    ref.child("users/\(ourID)/rider/requests/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong]);
                } else {
                    ref.child("users/\(self.offeredID)/rider/requests/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong]);
                }
            } else if (self.status == "accepted") {
                
                if(self.mode == "rider") {
                    ref.child("users/\(ourID)/rider/requests/accepted/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong]);
                } else {
                    ref.child("users/\(self.offeredID)/rider/requests/accepted/\(ourID)/origin").setValue( ["lat": self.ourlat, "long": self.ourlong]);
                }
            } else {
                print("something up with timer")
            }
        })
        
    }
    
    func changeStatus(status: String) {
        
        self.status = status;
        
    }
    
    func changeMode(mode: String) {
        self.mode = mode;
    }
    
    func getVenmoID() -> String {
        return self.driverVenmoID;
    }
    
    func startRiderObservers() {
        let ref = FIRDatabase.database().reference()
        ref.child("requests/immediate").observe( .childAdded, with: { snapshot in //.value allows us to see adds, removes, and lat/long updates.
            //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
            //let current = self.window?.rootViewController?.presentedViewController //not sure if this is the view controller we want.
            
            
            print("\n\n REQUEST OBSERVED!! \n\n")
            
            //MIGHT NEED TO ITERATE THROUGH THE SNAPSHOT SINCE ITS PULLING EVERYTHING DOWN EACH TIME WE OPEN/CLOSE THE APP.
            
            //let lastView = self._centerViewController //neeeds to be moved to
            //custom coding class and use KG's floating drawers and references instead of this whole floating drawers things.
            
            if(snapshot.value is NSNull) {
                print("snapshot null, doing nothing");
            } else {
                
                //and again need switch for casting etc.
                if( self._centerViewController is UITabBarController) {
                    
                    let vc = self.centerViewController as! UITabBarController
                    (vc.childViewControllers[0].childViewControllers[0] as! DriveViewController).ride_request(item: cellItem.init(snapshot: snapshot as FIRDataSnapshot))
                } else{
                    print("default")
                }
                
            }
        })
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("location being updated");
            locationManager.startUpdatingLocation()
            
        } else {
            print("\nNOT AUTHORIZED\n")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        ourlat = locValue.latitude
        ourlong = locValue.longitude
    }
}
