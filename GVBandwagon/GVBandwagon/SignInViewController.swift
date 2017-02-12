//
//  SignInViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/27/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Google

class SignInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet var googleSignInButton: GIDSignInButton!
    var isUserLoggedIn = false
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\nSIGNIN viewDidLoad called.\n")
        
        // Sign in
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        ref = FIRDatabase.database().reference()
        
        /*
        // If user is authorized/logged in, skip the login view.
        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil
        {
            print("\nSign In: USER IS NOT NIL. ID: \(currentUser?.uid)\n")
        }
        else
        {
            print("\nAppDelegate: USER IS NIL...LOADING LOGIN SCREEN\n")
        }
        // Sign in end
        */
        
        // Set UI delegate of GDSignIn object.
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // TODO(developer) Configure the sign-in button look/feel
        self.googleSignInButton.style = GIDSignInButtonStyle.wide
        
        // Check if user has a valid login/auth session.
        // If so, send them to RIDE view.
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
                print(user?.email ?? "no email found")
                print(user?.description ?? "no desc found")
                print(user?.uid ?? "no uid found")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
    
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
    
    // GIDSignInDelegate functions defined here. For handling actual sign in.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print("didSignInForUser ERROR: \(error.localizedDescription)")
            return
        }
        
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        // ...
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                print("sign in error: \(error.localizedDescription)")
                return
            }
            self.directUserToCorrectView()
        }
    }
    
    @nonobjc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func directUserToCorrectView() {
        // Check if user has registered already.
        // Firebase rule to add: auth != null && auth.uid == root.child('users').child(auth.uid).exists()
        // Hardcoded for 0001 so need to change:
        
        //also needs path updating check for riders or drivers path, query for true or false from the users state
        
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            //if the user is found in user state, then they are signInApproved, 
            //otherwise they need to register to add themselves to users or drivers 
            //and either way get an entry with their UID and a boolean value based on their choice into the database.
            
            guard snapshot.value! is Bool else {
                    self.performSegue(withIdentifier: "needsToRegister", sender: self)
                    return
                }
            
            //right here could do a check for if its true and thus the user is a driver, then they get added to active drivers.
            if(snapshot.value! as! Bool) {
                let tempRef = self.ref.child("activedrivers/\(userID)/")
                tempRef.setValue(NSDate().description)
                //sleep(2)
                //tempRef.removeValue()
                tempRef.onDisconnectRemoveValue() //on disconnect seems to only work when its a total loss of internet connection and not just the app being closed, will probably
                //just need/want to put something into the "prepare to disappear" functions of each view controller to try and see if the app is about to be backgrounded and we want to remove the 
                //driver from the active drivers section of the DB because if the app is not open, then we cannot pop up asking if they want to give a user a ride.
            }
            
            self.performSegue(withIdentifier: "signInApproved", sender: self)
            
        }) { (error) in
            print("directUser ERROR: \(error.localizedDescription)")
            
            self.performSegue(withIdentifier: "needsToRegister", sender: self)
    
        }
    }
}
