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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Go to func prepareDrawerViewController() to set initial views //

    var window: UIWindow?
    
    let kKGDrawersStoryboardName = "Main"
    
    let rideViewControllerStoryboardId = "rideViewControllerStoryboardId"
    let driveViewControllerStoryboardId = "driveViewControllerStoryboardId"
    let menuTableViewControllerStoryboardId = "menuViewControllerStoryboardId"
    let signInViewControllerStoryboardId = "signInViewControllerStoryboardId"
    
    let kKGDrawerSettingsViewControllerStoryboardId = "KGDrawerSettingsViewControllerStoryboardId"
    let kKGDrawerWebViewViewControllerStoryboardId = "KGDrawerWebViewControllerStoryboardId"
    let kKGLeftDrawerStoryboardId = "KGLeftDrawerViewControllerStoryboardId"
    let kKGRightDrawerStoryboardId = "KGRightDrawerViewControllerStoryboardId"
    
    // Overriding init() and putting FIRApp.configure() here to ensure it's configured before
    // the first view controller tries to retreive a reference to it.
    override init() {
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
        let drawerViewController = KGDrawerViewController()
        
        //drawerViewController.centerViewController = drawerSettingsViewController()
        //drawerViewController.leftViewController = leftViewController()
        
        // Set our initial view controllers here for menu and center:
        drawerViewController.centerViewController = rideViewController()
        drawerViewController.leftViewController = menuTableViewController()
        
        // Not using right drawer
        //drawerViewController.rightViewController = rightViewController()
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
    
    func driveViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: driveViewControllerStoryboardId)
        return viewController
    }
    
    func menuTableViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: menuTableViewControllerStoryboardId)
        return viewController
    }
    
    func signInViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(storyboardId: signInViewControllerStoryboardId)
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
}
