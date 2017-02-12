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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ref: FIRDatabaseReference!
    
    // Overriding init() and putting FIRApp.configure() here to ensure it's configured before
    // the first view controller tries to retreive a reference to it.
    override init() {
        super.init()
        FIRApp.configure()
        ref = FIRDatabase.database().reference()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
        
        // Moved to didFinish... below
        //GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if(FIRAuth.auth()!.currentUser == nil) {
            return
        } else {
        
            let userID = FIRAuth.auth()!.currentUser!.uid
            
            ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(snapshot.value! as! Bool) {
                let tempRef = self.ref.child("activedrivers/\(userID)/")
                tempRef.removeValue()
            }

            })
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if(FIRAuth.auth()!.currentUser == nil) { //use a guard and uid is string otherwise dont run, like sign in.
            return
        } else {
            
            let userID = FIRAuth.auth()!.currentUser!.uid
            
            ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(snapshot.value! as! Bool) {
                    let tempRef = self.ref.child("activedrivers/\(userID)/")
                    tempRef.removeValue()
                }
                
            })
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
            
            ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(snapshot.value! as! Bool) {
                    let tempRef = self.ref.child("activedrivers/\(userID)/")
                    tempRef.removeValue()
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
    
}

