//
//  AppDelegate.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

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
    
    let kKGDrawersStoryboardName = "Main"
    
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
    
    // Overriding init() and putting FIRApp.configure() here to ensure it's configured before
    // the first view controller tries to retreive a reference to it.
    override init() {
        
        categoryOffer = UNNotificationCategory(identifier: "offer_category", actions: [offerAction,dismissAction],
                                               intentIdentifiers: [], options: [])
        
        categoryAccept = UNNotificationCategory(identifier: "accept_category", actions: [ acceptAction, dismissAction],
                                                intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([categoryAccept, categoryOffer, categoryNothing])

        super.init()
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
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        let lastView = self._centerViewController //neeeds to be moved to
        //custom coding class and use KG's floating drawers and references instead of this whole floating drawers things.
        
        switch(lastView) {
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
        drawerViewController.backgroundImage = UIImage(named: "sky3")
        
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
    
    func rideViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: rideViewControllerStoryboardId)
        return viewController
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
        
        ref.child("users/\(userID)/rider/whiteList").observe( .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.riderWhiteList = localList;
        })
        
        ref.child("users/\(userID)/rider/blackList").observe( .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.riderBlackList = localList;
        })
        
        ref.child("users/\(userID)/driver/whiteList").observe( .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding((wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.driverWhiteList = localList;
        })
        
        ref.child("users/\(userID)/driver/blackList").observe( .value, with: { snapshot in
            var localList: NSArray = []
            for wl in snapshot.children {
                localList = localList.adding( (wl as! FIRDataSnapshot).key ) as NSArray;
            }
            self.driverBlackList = localList;
        })
        
        //watching for ride offers, and whitelist ride requests. BIG NOTE HERE ride acceptances will have to be watched for elsewhere/later when we know the uid that we will need to watch.
        ref.child("users/\(userID)/rider/offers/immediate").observe( .value, with: { snapshot in
            //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
            
            let lastView = self._centerViewController //neeeds to be moved to
            //custom coding class and use KG's floating drawers and references instead of this whole floating drawers things.
            
            //and again need switch for casting etc.
            
            // is lastView stupid/irrelephant?
            switch(lastView) {
            case is FirstViewController:
                let newView = self._centerViewController as! FirstViewController
                
                if(newView.isRider()) {
                    newView.ride_offer(item: cellItem.init(snapshot:snapshot as FIRDataSnapshot));
                } else {
                    //ignore alert
                }
            case is DriveViewController:
                print("ignore alert? if its a driver controller on screen and its a rider offer notification")
                
            default:
                //local notification creation.
                let localCell = cellItem.init(snapshot: snapshot)
                
                let content = UNMutableNotificationContent()
                content.title = "New Driver Offer"
                content.body = "Navigate to the riders map to see the new pin/offer"
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "nothing_category"
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
                
                let localFirst = FirstViewController()
                localFirst.ride_offer(item: localCell);
                
            }
            
            
            //make other view controllers follow the protocols.
        })
        
        ref.child("requests/immediate").observe( .value, with: { snapshot in //.value allows us to see adds, removes, and lat/long updates.
            //if we are in a riders portion of the app, currentViewController has rider offers function, call it, there we load the view however we want.
            //let current = self.window?.rootViewController?.presentedViewController //not sure if this is the view controller we want.
            
            
            let lastView = self._centerViewController //neeeds to be moved to
            //custom coding class and use KG's floating drawers and references instead of this whole floating drawers things.
            
            //and again need switch for casting etc.
            switch(lastView) {
                case is FirstViewController:
                    print("ignoring the observe, doing rider things")
                case is DriveViewController:
                    
                    // TO DO, set up the observers to highlight or ignore white and black listed riders/drivers
                    
                    // and in here is where you would make the call of if its a white listed rider or not.
                    // OR if its a black listed rider to ignore the requests.
                    
                    let newView = lastView as! DriveViewController
                    newView.ride_request(item: cellItem.init(snapshot: snapshot as FIRDataSnapshot))
                
                default:
                    //local notification creation.
                    let localCell = cellItem.init(snapshot: snapshot)
                    
                    let content = UNMutableNotificationContent()
                    content.title = "New Rider Request"
                    content.body = "Navigate to the drivers map to see the new pin/request"
                    content.sound = UNNotificationSound.default()
                    content.categoryIdentifier = "nothing_category"
                    content.userInfo = localCell.toAnyObject() as! [AnyHashable : Any] //compiler forced the conversion.
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    let identifier = "Rider request"
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: { (error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                    
                    let localDriver = DriveViewController() //hopefully these local redeclarations hold.
                    localDriver.ride_request(item: localCell)
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
            
            let current = self._centerViewController
            
            switch(current){
            //switches and casts here
            case is DriveViewController:
                    let localcurrent = current as! DriveViewController
                    localcurrent.ride_accept(item: cellItem.init(snapshot: snapshot as FIRDataSnapshot)); //and then on the other end, if the accept really iss an accept, then we announce as much, otherwise not so much.
            default:
                // to do
                print("local notification here about offer acceptance");
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
    
}
