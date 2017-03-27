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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\nSIGNIN viewDidLoad called.\n")
        self.googleSignInButton.isEnabled = true
        
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
                
                let alert = UIAlertController(title: "Sign In error", message: "Grand Valley Email Addresses Only.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                    (action) in print("No offer")
                }))
                
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
    
    func directUserToCorrectView() {            //CURRENTLY IS NOT BEING CALLED. DISCUSS THIS AT SOME POINT.
        // Check if user has registered already.
        // Firebase rule to add: auth != null && auth.uid == root.child('users').child(auth.uid).exists()
        // Hardcoded for 0001 so need to change:
        
        //also needs path updating check for riders or drivers path, query for true or false from the users state
        
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        print("our ID: \(userID)")
        
        ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { snapshot in
            //if the user is found in user state, then they are signInApproved, otherwise they need to register to add themselves to users or drivers and either way get an entry with their UID and a 
            //boolean value based on their choice into the database.
            
            guard snapshot.value! is Bool else { //this was working at one point and now isnt. not sure what happened...
                print("our value: \(snapshot.value!)") //might need to work on this....
                    self.performSegue(withIdentifier: "needsToRegister", sender: self)
                    return //not sure if necessary but it silences the auto compilier.
                }
            print("our value \(snapshot.value!)")
            
            // Load up the drawer from AppDelegate:
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate // could it be this redeclaration be the issue?
            self.appDelegate.initiateDrawer()
            self.appDelegate.setUpOpenObservers();
            
            //self.performSegue(withIdentifier: "signInApproved", sender: self)
            
            /* if(ref.child("users").child("\(userID)").) {
                self.performSegue(withIdentifier: "signInApproved", sender: self)
            } else {
                self.performSegue(withIdentifier: "needsToRegister", sender: self)
            } */
            
        }) { (error) in //hopefully them not being found in userstate will return an error that can then be used to allow the person to register.
            print("directUser ERROR: \(error.localizedDescription)")
            
            self.performSegue(withIdentifier: "needsToRegister", sender: self)
    
        }
    }
    
    @IBAction func onSignInTapped(_ sender: Any) {
        
        // Disable so multiple taps are not allowed.
        //self.googleSignInButton.isEnabled = false
        print("Sign In Button Clicked.")
    }
    
}
