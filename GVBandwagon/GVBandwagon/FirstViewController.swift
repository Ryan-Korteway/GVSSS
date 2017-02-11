//
//  FirstViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class FirstViewController: UIViewController {


    @IBOutlet var fromContainerView: UIView!
    @IBOutlet var fromView: UIView!
    @IBOutlet var toView: UIView!
    @IBOutlet var toContainerView: UIView!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var signOutButton: UIBarButtonItem!
    
    var containerDelegate: ContainerDelegate? = nil
    
    //let userid = "0001" //hardcoded values, should be the fireauth current user stuff.
    let currentUser = FIRAuth.auth()!.currentUser
    let pickerData: [String] = ["Allendale", "Meijer", "Downtown"]
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Link to pay on venmo
        UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@michael-christensen-20&amount=3&note=GVB") as! URL, options: [:], completionHandler: nil)
         */
        
        self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: 0)
        self.toContainerView.frame = CGRect(x: self.toContainerView.frame.origin.x, y: self.toContainerView.frame.origin.y, width: self.toContainerView.frame.width, height: 0)
        
        // COPY FOR POP UP'S ABOUT RIDER DRIVR OFFERS STARTS HERE.
       
        let driverRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/driver/")
        let riderRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/rider/")
        var riderfirst = true;
        var driverfirst = true;
        
        driverRef.child("rider_found").observe(.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if (driverfirst) {
                driverfirst = false;
            } else {
                    //may need to further restrict the alert so that it does not pop up when the riderfound value is being reset to false.
                
                if(snapshot.value! as! Bool) {
                    
                        driverRef.child("rider_uid").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            //let user = self.ref.child("users/\(snapshot.value!)").queryEqual(toValue: "name")
                            self.ref.child("users/\(snapshot.value!)/name").observeSingleEvent(of: .value , with: { (innerSnapshot) in
                                //ALL OF THIS WORKS OTHER THAN THE QUERY NOT BRINGING UP THE RIDERS ACTUAL NAME!!!
                                
                                let alert = UIAlertController(title:"Rider Found", message:"Would you like to give \(innerSnapshot.value!) a ride?",
                                    preferredStyle: .actionSheet)
                                
                                let yesAction = UIAlertAction(title:"Yes", style:.default) { action -> Void in
                                    //code for the action can go here. so accepts or deny's
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_uid").setValue(self.currentUser!.uid)
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_found").setValue(true)
                                }
                                
                                let noAction = UIAlertAction(title:"No", style:.default) { action -> Void in
                                    //code for the action can go here. so accepts or deny's
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_uid").setValue("none")
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_found").setValue(true)
                                }
                                
                                alert.addAction(yesAction)
                                alert.addAction(noAction)
                                self.present(alert, animated:true, completion:nil)
                                driverRef.child("rider_found").setValue(false)
                                
                            })

                        })
                }
            }
        })

        riderRef.child("driver_found").observe(.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if (riderfirst) {
                riderfirst = false;
            } else {
                //may need to further restrict the alert so that it does not pop up when the riderfound value is being reset to false.
                
                if(snapshot.value! as! Bool) {
                    riderRef.child("driver_uid").observeSingleEvent(of: .value, with: { (snapshot) in
                    //inner if for accepted, else for rejected.
                    if( snapshot.value! as! String == "none") {
                        let alert = UIAlertController(title:"Driver Alert", message:"We are sorry but this driver is unavailable.", preferredStyle: .actionSheet);
                        
                        let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                            //code for the action can go here. so accepts or deny's
                            riderRef.child("driver_found").setValue(false)
                        }
                        
                        alert.addAction(defaultAction);
                        self.present(alert, animated:true, completion:nil);
                        
                    } else {
                        
                        let alert = UIAlertController(title:"Driver Alert", message:"The driver has accepted.", preferredStyle: .actionSheet);
                        //maybe add a see profile action that triggers a seque to a page that pre fills itself with the drivers info based on his UID?
                        
                        let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                            //code for the action can go here. so accepts or deny's
                            riderRef.child("driver_found").setValue(false)
                        }
                        
                        alert.addAction(defaultAction);
                        self.present(alert, animated:true, completion:nil);
                    } //inner else end

                    
                }) //inner snapshot end
                
               } //outer if end
           } //outer else end
        }) //observe end        COPY STOPS HERE
        
    } //end of view did load.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //nameField.resignFirstResponder() // User with picker?
    }
    
    func updateUserInfo(name: String, phone: String) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        self.ref.child("users/\(userID)/name").setValue(name)
        self.ref.child("users/\(userID)/phone").setValue(phone)
    }
    
    @IBAction func onMenuTapped(_ sender: Any) {
        guard let menuOpen = self.containerDelegate?.menuShown else {
            print("containerDelegate or it's menuShown field is nil!")
            return
        }
        if (menuOpen) {
            self.containerDelegate?.hideMenu()
        } else {
            self.containerDelegate?.showMenu()
        }
    }
    
    @IBAction func onSignOutTapped(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth!.signOut()
            performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func onViewTapped(_ sender: Any) {
        guard let menuOpen = self.containerDelegate?.menuShown else {
            print("containerDelegate or it's menuShown field is nil!")
            return
        }
        if (menuOpen) {
            self.containerDelegate?.hideMenu()
        }
    }
    
    
    // For these two, add animation to move labels at the same time.
    
    @IBAction func onFromViewTapped(_ sender: Any) {
        var frameHeight: CGFloat = 0
        
        if (self.fromContainerView.frame.height == 0) {
            frameHeight = 250
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: frameHeight)
        }, completion: { (Bool) -> Void in
            // what to do when completed animation.
        })
    }
    
    @IBAction func onToViewTapped(_ sender: Any) {
        var frameHeight: CGFloat = 0
        
        if (self.toContainerView.frame.height == 0) {
            frameHeight = 250
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.toContainerView.frame = CGRect(x: self.toContainerView.frame.origin.x, y: self.toContainerView.frame.origin.y, width: self.toContainerView.frame.width, height: frameHeight)
        }, completion: { (Bool) -> Void in
            // what to do when completed animation.
        })
    }
    
    
}

