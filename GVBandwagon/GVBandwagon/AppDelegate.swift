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
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Go to func prepareDrawerViewController() to set initial views //

    var window: UIWindow?
    
    var timer = Timer()
    
    //--- THE KEY VARIABLES WE WOULD HAVE TO STORE IN FIREBASE AND RETRIEVE BETWEEN LAUNCHES TO RESUME WHERE WE LEFT OFF.
    var riderStatus = "request";
    var driverStatus = "request";
    var mode = "rider";
    var offeredID = "none"; //the id of the offered rider, to be set when we offer a ride to someone.
    var riderAddress = ""
    //---------------------------
    
    var locationManager = CLLocationManager()
    
    var ourlat : CLLocationDegrees = 0.0
    var ourlong : CLLocationDegrees = 0.0
    var ourAddress : NSString?
    
    let kKGDrawersStoryboardName = "Main"
    
    let rideNavControllerStoryboardId = "rideNavController"
    let rideViewControllerStoryboardId = "rideViewControllerStoryboardId"
    let driveViewControllerStoryboardId = "driveViewControllerStoryboardId"
    let menuTableViewControllerStoryboardId = "menuViewControllerStoryboardId"
    let signInViewControllerStoryboardId = "signInViewControllerStoryboardId"
    let settingsNavControllerStoryboardId = "settingsNavigationController"
    let driveTabBarControllerStoryboardId = "driveTabBarController"
    let driverPanelViewControllerStoryboardId = "driverPanelViewController"
    let helpNavControllerStoryboardId = "helpNavControllerStoryboardId"
    let profileNavigationControllerStoryboardId = "profileNavigationControllerStoryboardId"
    let historyNavigationControllerStoryboardId = "historyNavigationControllerStoryboardId"
    
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
    
    var isSwitched = false
    
    //the arrays of favorite and disfavored riders/drivers for a given user.
    var riderWhiteList: NSArray = []
    var riderBlackList: NSArray = []
    var driverWhiteList: NSArray = []
    var driverBlackList: NSArray = []
    var lastState = "rider"
    
    var driverVenmoID = "none" //the drivers venmo ID to be updated etc.
    
    var firstViewController = UIViewController()
    var firstSet = false
    var DriveViewController_AD = UIViewController()
    var DriveSet = false
    var PanelViewController = UIViewController() 
    
    // Overriding init() and putting FIRApp.configure() here to ensure it's configured before
    // the first view controller tries to retreive a reference to it.
    override init() {
        
        categoryOffer = UNNotificationCategory(identifier: "offer_category", actions: [offerAction,dismissAction],
                                               intentIdentifiers: [], options: [])
        
        categoryAccept = UNNotificationCategory(identifier: "accept_category", actions: [ acceptAction, dismissAction],
                                                intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([categoryAccept, categoryOffer, categoryNothing])

        super.init()
        
        let date = Date() //THIS WORKS FOR TIME GRABBING.
        print("\(date.description)")
        
        FIRApp.configure()
        // not really needed unless you really need it 
        //FIRDatabase.database().persistenceEnabled = true;
        
        //selective persistence possible? save the writes and removes but dont save old data...
        
        // Moved to didFinish... below
        //GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // For Google Maps and Places:
        GMSServices.provideAPIKey("AIzaSyCGT0W7GBgr5dWY0E60RvwZatwKmTDT7u8")
        GMSPlacesClient.provideAPIKey("AIzaSyCGT0W7GBgr5dWY0E60RvwZatwKmTDT7u8")
        
        // Make sign in the root view controller UNLESS they are already signed in.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // If user is not signed in...
        let signInVC = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
        window?.rootViewController = signInVC
        
        // If user IS signed in...
        //window?.rootViewController = drawerViewController
        // OR
        // self.initiateDrawer()
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong with notifications")
            }
        }
        
        window?.makeKeyAndVisible()
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        
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
            
            self.closedRideAccept(toWatchUid: offeredID);
            
            ref.child("users/\(userID)/stateVars").setValue(["riderStatus" : riderStatus, "driverStatus" : driverStatus, "offeredID" : offeredID])
            
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if(FIRAuth.auth()!.currentUser != nil) {
            setUpOpenObservers();
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
            
            ref.child("users/\(self.offeredID)/rider/accepted/immediate").removeAllObservers();
            
            ref.child("requests/immediate").removeAllObservers();
            
            ref.child("users/\(userID)/stateVars").setValue(["riderStatus" : riderStatus, "driverStatus" : driverStatus, "offeredID" : offeredID])
            
            ref.child("activedrivers").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(snapshot.value != nil) {
                    let tempRef = ref.child("activedrivers/\(userID)/")
                    tempRef.removeValue()
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
    
    // We do not have one of these in our storyboard, so this could crash:
    // -------------------
    func drawerSettingsViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: kKGDrawerSettingsViewControllerStoryboardId)
        return viewController
    }
    
    func profileNavigationController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: profileNavigationControllerStoryboardId)
        return viewController as! UINavigationController
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
    
    func historyNavigationController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: historyNavigationControllerStoryboardId)
        return viewController as! UINavigationController
    }
    
    func helpNavController() -> UINavigationController {
        let viewController = viewControllerForStoryboardId(storyboardId: helpNavControllerStoryboardId)
        return viewController as! UINavigationController
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
            let userID = FIRAuth.auth()!.currentUser!.uid
            let ref = FIRDatabase.database().reference()
            ref.child("users/\(userID)/stateVars").setValue(["riderStatus" : riderStatus, "driverStatus" : driverStatus, "offeredID" : offeredID])
            
            try firebaseAuth!.signOut()
            print("Successfully signed out user.")
            
            
            //performSegue(withIdentifier: "signOutSegue", sender: self)
            //let signInVC = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
            
            //window?.rootViewController = signInVC //i think its this transfer back that is preventing our signing out and back in...
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func initiateDrawer() {
        window?.rootViewController = drawerViewController
        window?.makeKeyAndVisible()
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
            } //this may not be working.
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
    
    func closedRideAccept(toWatchUid: String) {
        
        let ref = FIRDatabase.database().reference();
        
        ref.child("users/\(self.offeredID)/rider/offers/immediate").observeSingleEvent(of: .childRemoved, with: { snapshot in
            let localCell = cellItem.init(snapshot: snapshot)
            
            let content = UNMutableNotificationContent()
            content.title = "Ride Offer Response"
            
            if(localCell.accepted == 1) {
                content.body = "Your ride offer has been accepted."
                self.driverStatus = "accepted"
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
        
        
            print("timer firing");
            
            if(self.mode == "rider") {
            
                if(self.riderStatus == "request") {
                    
                        ref.child("requests/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong, "address": self.ourAddress!]);
                    
                } else if (self.riderStatus == "offer") {
                    
                        ref.child("users/\(ourID)/rider/offers/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong, "address": self.ourAddress!]);
            
                } else if (self.riderStatus == "accepted") {
                    
                        ref.child("users/\(ourID)/rider/offers/accepted/immediate/rider/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong, "address": self.ourAddress!]);
                   
                } else {
                    print("something up with timer")
                }
                
            } else { // mode == driver, cant let the driver wipe out the riders origin address...
             
                if(self.driverStatus == "request") {
                    
                        ref.child("activedrivers/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong, "address": self.riderAddress]);
                    
                } else if (self.driverStatus == "offer") {
                    
                        ref.child("users/\(self.offeredID)/rider/offers/immediate/\(ourID)/origin").setValue(["lat": self.ourlat, "long": self.ourlong, "address": self.riderAddress]);
                    
                } else if (self.driverStatus == "accepted") {
                    
                        ref.child("users/\(self.offeredID)/rider/offers/accepted/immediate/driver/\(ourID)/origin").setValue( ["lat": self.ourlat, "long": self.ourlong, "address": self.riderAddress]);
                    
                } else {
                    print("something up with timer")
                }
                
            }
            
        })
        
    }
    
    func changeRiderStatus(status: String) {
        self.riderStatus = status;
    }
    
    func changeDriverStatus(status: String) {
        self.driverStatus = status;
    }
    
    func changeMode(mode: String) {
        self.mode = mode;
    }
    
    func getVenmoID() -> String {
        return self.driverVenmoID;
    }
    
    
    /*
     
     The method called to repopulate the DRIVER MAP depending on what is going on with the statuses
     
     */
    func startDriverMapObservers() {
        
        let ref = FIRDatabase.database().reference()
        
        if(self.driverStatus == "request") {
            
            ref.child("requests/immediate").observe( .childAdded, with: { snapshot in //observe single event of .value which allows us to loop through each pin/request to properly recreate the map.
                
                print("\n\n REQUEST OBSERVED!! \n\n")
                
                if(snapshot.value == nil) {
                    print("snapshot null, doing nothing");
                } else {
                    
                    //and again need switch for casting etc.
                    if( !self.DriveSet) {
                        print("driver view controller not ready yet.")
                        
                    } else{
                        (self.DriveViewController_AD as! DriveViewController).ride_request(item: cellItem.init(snapshot: snapshot))
                    }
                    
                }
            })
        } else if (self.driverStatus == "accepted"){
            ref.child("requests/immediate").removeAllObservers();
            ref.child("users/\(self.offeredID)/rider/offers/accepted/immediate/rider/").observeSingleEvent(of: .childAdded, with: { snapshot in
                    (self.DriveViewController_AD as! DriveViewController).fillWithAcceptance(item: cellItem.init(snapshot: snapshot))
            })
        } else if (self.driverStatus == "offer"){
            //rides being offered by the driver, need to get the users pin back.
                //offeredID is usable to reclaim the offered riders id/path.
            
            //watched the offered path for deletions and then call ride accepted in the driver view controller.
            ref.child("requests/immediate").removeAllObservers();
            ref.child("users/\(self.offeredID)/rider/offers/immediate").observe( .childRemoved, with: { snapshot in
                
                print("we are calling ride accept")
                (self.DriveViewController_AD as! DriveViewController).ride_accept(item: cellItem.init(snapshot: snapshot))
                //acceptsToWatch = acceptsToWatch.adding(toWatchUid) as NSArray; //not sure about where this line should go. its purpose is to track which userID needs to be watched when we call the closed observer set up function.
            })
            
        }
    }
    
    
    /* 
     
     The method called to repopulate the RIDER MAP depending on what is going on with the statuses
     
     */
    func startRiderMapObservers() {
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        print("our status: \(riderStatus)")
        
        if(self.riderStatus == "request") {
            //this isnt even the right code/observer to calling if in request status....
            
            ref.child("users/\(userID)/rider/offers/immediate").observe( .childAdded, with: { snapshot in //.value allows us to see adds, removes, and lat/long updates.
                //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
                //let current = self.window?.rootViewController?.presentedViewController //not sure if this is the view controller we want.
                
                
                print("\n\n offer OBSERVED!! \n\n")
                
                if(snapshot.value == nil) {
                    print("snapshot null, doing nothing");
                } else {
                    
                    //and again need switch for casting etc.
                    if( !self.firstSet) {
                        print("rider view controller not ready yet.")
                        
                    } else {
                            (self.firstViewController as! FirstViewController).ride_offer(item: cellItem.init(snapshot: snapshot))
                    }
                    
                }
            })
        } else if (self.riderStatus == "accepted"){ //path needs to go deeper....
            ref.child("users/\(userID)/rider/offers/accepted/immediate/driver/").observeSingleEvent(of: .value, with: { snapshot in //child added may be an issue here...
                print(snapshot.key)
                for item in snapshot.children{
                    (self.firstViewController as! FirstViewController).fillWithAcceptance(item: cellItem.init(snapshot: (item as! FIRDataSnapshot)))
                    
                }
                
            })
        } //no else for status == request because request is the base which means we dont have any position to advertise or any pins to recreate
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
        
        //here set ourAddress to the google places address.
        
        // Get riders current place
        let placesClient = GMSPlacesClient.shared()
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // address = an NSString of the address where the user is.
            if let place = placeLikelihoodList?.likelihoods.first?.place {
                if let address = place.formattedAddress {
                    self.ourAddress = (address as NSString?)!
                }
            }
        })
        // End get riders current place
        
        ourlat = locValue.latitude
        ourlong = locValue.longitude
    }
}
