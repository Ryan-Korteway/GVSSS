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
import GoogleMaps

protocol RideSceneDelegate {
    var startingFrom: String {get set}
    var goingTo: String {get set}
    func onFromViewTapped(_ sender: Any)
    func onToViewTapped(_ sender: Any)
}

class FirstViewController: UIViewController, RideSceneDelegate {


    @IBOutlet var rideNowButton: UIButton!
    @IBOutlet var scheduleRideButton: UIButton!
    @IBOutlet var fromContainerView: UIView!
    @IBOutlet var fromView: UIView!
    @IBOutlet var toView: UIView!
    @IBOutlet var toContainerView: UIView!
    @IBOutlet var signOutButton: UIBarButtonItem!
    @IBOutlet var superViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var googleMapsView: GMSMapView!
    @IBOutlet var headerView: UIView!
    
    var fromTableViewController: RideFromTableViewController?
    var toTableViewController: RideToTableViewController?
    
    var containerDelegate: ContainerDelegate?
    
    var startingFrom: String = "Bing"
    var goingTo: String = "Bong"
    
    //let userid = "0001" //hardcoded values, should be the fireauth current user stuff.
    let currentUser = FIRAuth.auth()!.currentUser
    let pickerData: [String] = ["Allendale", "Meijer", "Downtown"]
    
    let ref = FIRDatabase.database().reference()
    var uid_forDriver = "wait";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rideNowButton.layer.borderWidth = 1
        self.rideNowButton.layer.borderColor = UIColor.blue.cgColor
        
        self.scheduleRideButton.layer.borderWidth = 1
        self.scheduleRideButton.layer.borderColor = UIColor.blue.cgColor
        
        /* Link to pay on venmo
        UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@michael-christensen-20&amount=3&note=GVB") as! URL, options: [:], completionHandler: nil)
         */
        
        self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: 0)
        self.toContainerView.frame = CGRect(x: self.toContainerView.frame.origin.x, y: self.toContainerView.frame.origin.y, width: self.toContainerView.frame.width, height: 0)
        
        // COPY FOR POP UP'S ABOUT RIDER DRIVR OFFERS STARTS HERE.
       
        let riderRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/rider/")
        var riderfirst = true;
        
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
        
        ref.child("users/\(currentUser!.uid)/rider/driver_uid").observe(.value, with: { (snapshot) in
            self.uid_forDriver = snapshot.value! as! String ;
        })
        
        self.createMap()
        self.googleMapsView.reloadInputViews()
        
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
        print("View has been tapped.")
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
        //var moveToLabelBy: CGFloat = -250
        var toViewAlpha: CGFloat = 1
        self.superViewTapGesture.isEnabled = true
        
        if (self.fromContainerView.frame.height == 0) {
            frameHeight = 250
            //moveToLabelBy = 250
            toViewAlpha = 0
            
            // We need to disable this tap GR so we can click the cells
            // in the container view.
            self.superViewTapGesture.isEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: frameHeight)
            //self.toView.frame  = CGRect(x: self.toView.frame.origin.x, y: self.toView.frame.origin.y + moveToLabelBy, width: self.toView.frame.width, height: self.toView.frame.height)
            self.toView.alpha = toViewAlpha
            
            /* TODO: Attempts to dim surrounding views */
            //self.view.backgroundColor = UIColor.black
            //self.view.backgroundColor?.withAlphaComponent(0.5)
            
            // get your window screen size
            //let screenRect = UIScreen.main.bounds
            //create a new view with the same size
            //let coverView = UIView(frame: screenRect)
            // change the background color to black and the opacity to 0.6
            //coverView.backgroundColor = UIColor.black
            //coverView.backgroundColor = coverView.backgroundColor?.withAlphaComponent(0.6)
            // add this new view to your main view
            //self.view.addSubview(coverView)
            
        }, completion: { (Bool) -> Void in
            // what to do when completed animation.
        })
    }
    
    @IBAction func onToViewTapped(_ sender: Any) {
        var frameHeight: CGFloat = 0
        var buttonAlpha: CGFloat = 1
        self.superViewTapGesture.isEnabled = true
        
        if (self.toContainerView.frame.height == 0) {
            frameHeight = 250
            buttonAlpha = 0
            
            // We need to disable this tap GR so we can click the cells
            // in the container view.
            self.superViewTapGesture.isEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.toContainerView.frame = CGRect(x: self.toContainerView.frame.origin.x, y: self.toContainerView.frame.origin.y, width: self.toContainerView.frame.width, height: frameHeight)
            
            // Hide the button
            //self.findDriverButton.alpha = buttonAlpha
            
        }, completion: { (Bool) -> Void in
            // what to do when completed animation.
        })
    }
    
    
    // TODO: Ryan, here you could hardcode some lats/longs (location objects) to use for
    // storing in Firebase, etc. Instead of getting the users current location, just
    // use the hardcoded location, then everything else with Firebase should be as usual.
    // Feel free to change anything in this function:
    @IBAction func onFindTapped(_ sender: Any) {
        if (self.startingFrom == "Null" || self.goingTo == "Null") {
            // Display a pop telling the user they must select a From and To location
            print("Select a FROM and TO location.")
            return
        } else {
            // TODO: Send the locations to Firebase
            print("Leaving from \(self.startingFrom)")
            print("Going to \(self.goingTo)")
            
            ref.child("users/\(currentUser!.uid)/location/").setValue(["start": self.startingFrom, "stop": self.goingTo]) //locations being sent here.
            
            ref.child("activedrivers").queryOrdered(byChild: "jointime").observeSingleEvent(of: .value, with: { snapshot in //needs to be singleevent of.
                
                for driver in snapshot.children {
                    print((driver as! FIRDataSnapshot).key)
                    print((driver as! FIRDataSnapshot).childSnapshot(forPath: "location").value as! NSDictionary) //this could be it for group value pull down.
                    let driver_dict = (driver as! FIRDataSnapshot).childSnapshot(forPath: "location").value as! NSDictionary
                    
                    if ( driver_dict["start"] as! String == "Bing" && driver_dict["end"] as! String == "Bong" ) { //Bing and Bong are hardcoded values for the sake of testing and demonstrations.
                        
                        self.ref.child("users/\((driver as! FIRDataSnapshot).key)/driver/rider_uid").setValue(self.currentUser!.uid)
                        self.ref.child("users/\((driver as! FIRDataSnapshot).key)/driver/rider_found").setValue(true)
                        
                        print(self.uid_forDriver)
                        
                        sleep(30) //neither sleep nor infinite wait loop will do it... ACTUALLY SHOULD WORK BETWEEN DEVICES, JUST NOT FROM ONE USER TO THE SAME USER.
                        
                        //set a timer perhaps and when it goes off in 30 seconds, trigger this pop up etc... idk still how we would wait without freezing the app...
                        
                        print(self.uid_forDriver)
                        
                        if (self.uid_forDriver != "none") {
                            let alert = UIAlertController(title:"Driver Alert", message:"Your Driver has been found. They are on their way.", preferredStyle: .alert);
                            
                            let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                            }
                            
                            alert.addAction(defaultAction);
                            self.present(alert, animated:true, completion:nil);
                            
                            return
                        }//end if
                    }
                    
                }
                
                let alert = UIAlertController(title:"Driver Alert", message:"We are sorry but there are no drivers.", preferredStyle: .alert);
                
                let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                }
                
                alert.addAction(defaultAction);
                self.present(alert, animated:true, completion:nil);
                
                //no drivers means set the driver_uid value to "none" 
                
                return
                
            })
            
            print("about to leave find driver");
            
            return;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFromTableVC" {
            self.fromTableViewController = segue.destination as? RideFromTableViewController
            self.fromTableViewController?.rideDelegate = self
        }
        
        if segue.identifier == "toToTableVC" {
            self.toTableViewController = segue.destination as? RideToTableViewController
            self.toTableViewController?.rideDelegate = self
        }
    }

    @IBAction func toggleLeftDrawer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender: sender as AnyObject, animated: false)
    }
    
    func createMap() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.googleMapsView.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.googleMapsView
    }

    
}

