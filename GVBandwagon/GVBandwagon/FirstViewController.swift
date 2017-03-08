//
//  FirstViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class FirstViewController: UIViewController {

    @IBOutlet var rideNowButton: UIButton!
    @IBOutlet var scheduleRideButton: UIButton!
    @IBOutlet var superViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var googleMapsView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
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
        
        //user location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .automotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.createMap()
        
    } //end of view did load.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserInfo(name: String, phone: String) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        self.ref.child("users/\(userID)/name").setValue(name)
        self.ref.child("users/\(userID)/phone").setValue(phone)
    }
    
    
    // Ride Now button. Inside code, will add UI elements later.
    // Looking into adding an on-screen "bar" for searching up addresses, etc.
    // Will take some time.
    @IBAction func onRideNowTapped(_ sender: Any) {
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
    
    // Plan on doing the same for Schedule Ride button as Ride Now.
    // Would rather have a view pop up over the map in which the user
    // can enter info rather than switch to a entirely new view controller.
    @IBAction func onScheduleRideTapped(_ sender: Any) {
    }

    @IBAction func toggleLeftDrawer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender: sender as AnyObject, animated: false)
    }
    
    func createMap() {
        
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
    }
}

extension FirstViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            self.googleMapsView.isMyLocationEnabled = true
            self.googleMapsView.settings.myLocationButton = true
        } else {
            print("\nNOT AUTHORIZED\n")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            //self.googleMapsView.animate(to: camera)
            self.googleMapsView.camera = camera
            
            locationManager.stopUpdatingLocation()
        } else {
            print("No location found!")
        }
    }
}
