//
//  DriverPanelViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import CoreFoundation
import GoogleMaps

class DriverPanelViewController: UIViewController {

    @IBOutlet var goOnlineLabel: UILabel!
    @IBOutlet var goOnlineSwitch: UISwitch!
    @IBOutlet var activeTripLabel: UILabel!
    @IBOutlet var activeTripView: UIView!
    @IBOutlet var scheduledRidesContainerView: UIView!
    @IBOutlet var yourRatingLabel: UILabel!
    @IBOutlet var contentsView: UIView!
    
    @IBOutlet var ratingImageView: UIImageView!
    var totalTrips = 0
    
    var mode = "Ride"
    var activeTripExists = false
    
    var ourlat : CLLocationDegrees = 0.0
    var ourlong : CLLocationDegrees = 0.0
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let locationManager = CLLocationManager()
    
    let ref = FIRDatabase.database().reference()
    let ourid = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goOnlineSwitch.setOn(false, animated: false)
        self.goOnlineSwitch.addTarget(self, action: #selector(switchIsChanged(mySwitch:)), for: .valueChanged)
        
        getRating()
        getActiveTrip()
        viewReload()
        localDelegate.PanelViewController = self
    }
    
    func viewReload() {
        if(mode == "Driver") {
            
            ref.child("users/\(ourid)/driver/totalRiders/").observeSingleEvent(of: .value, with: { snapshot in
                print("key " + snapshot.key)
                print("value  \((snapshot.value as? NSInteger)!)")
                //Removed//self.tripCounterLabel.text = "\((snapshot.value as? NSInteger)!) trips."
            })
            
        } else {
            
            ref.child("users/\(ourid)/rider/totalRides/").observeSingleEvent(of: .value, with: { snapshot in
                print("key " + snapshot.key)
                print("value  \((snapshot.value as? NSInteger)!)")
                //Removed//self.tripCounterLabel.text = "\((snapshot.value as? NSInteger)!) trips."
            })
        }
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if mySwitch.isOn {
            appDelegate.toggleRightDrawer(sender: mySwitch, animated: true)
            let centerVC = appDelegate.centerViewController as? UITabBarController
            let driveVC = centerVC?.childViewControllers[0].childViewControllers[0] as? DriveViewController
            driveVC?.displayOnlineMessage()

            
            ref.child("/activedrivers/\(ourid)").setValue(["name": FIRAuth.auth()!.currentUser!.displayName! as NSString,
                                                           "uid": ourid, "venmoID": localDelegate.getVenmoID(), "origin": ["lat": ourlat, "long": ourlong],
                                                        "destination": ["latitude": "none", "longitude": "none"],
                                                           "rate" : 0, "accepted": 0, "repeats": "none", "date": "none"]) //need protections of if destination is none, dont make a pin.
        
            localDelegate.changeMode(mode: "driver")
            localDelegate.changeDriverStatus(status: "request")
            localDelegate.isSwitched = true
            localDelegate.startTimer()
            localDelegate.startDriverMapObservers()
        } else {
            // Remove driver from active driver list
            ref.child("/activedrivers/\(ourid)").removeValue();
            localDelegate.changeMode(mode: "rider")
            localDelegate.changeDriverStatus(status: "none")
            (localDelegate.DriveViewController_AD as! DriveViewController).googleMap.clear()
            localDelegate.isSwitched = false
            localDelegate.timer.invalidate() //stop the timer.
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func activeTripTapped(_ sender: Any) {
        // Check if there is one, if not do nothing.
        
        if (!activeTripExists) {
            return
        }
        
        // If there is an active trip, load the summary.
        //self.performSegue(withIdentifier: "driverAcceptsRide", sender: self)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let centerVC = appDelegate.drawerViewController.centerViewController
        
        //EITHER WAY THE SEGUE SHOULD PROVIDE THE RECIEVING VIEW CONTROLLER A CELL ITEM OF DATA TO PULL FROM
        
        if (self.mode == "Ride") {
            let rideVC = centerVC?.childViewControllers[0]
            appDelegate.toggleRightDrawer(sender: self, animated: true)
            rideVC?.performSegue(withIdentifier: "riderAcceptsSegue", sender: rideVC)
        } else {
            let driveVC = centerVC?.childViewControllers[0].childViewControllers[0]
            appDelegate.toggleRightDrawer(sender: self, animated: true)
            driveVC?.performSegue(withIdentifier: "driverAcceptsSegue", sender: driveVC)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "riderAcceptsSegue") {
            (segue.destination as! RideSummaryTableViewController).mode = "ride"
            (segue.destination as! RideSummaryTableViewController).localAddress = localDelegate.ourAddress as! String
        } else if (segue.identifier == "driverAcceptsSegue") {
            (segue.destination as! RideSummaryTableViewController).mode = "drive"
            (segue.destination as! RideSummaryTableViewController).localAddress = localDelegate.riderAddress
            
        }
    }
    
    // Get active trip from FB?
    func getActiveTrip() {
        // Get trip info from FB
        
        // If active trip exists then
        self.activeTripExists = true
        
        // else
        //self.activeTripExists = false
    }
    
    // Get rating from FB. Return stars based on rounded to nearest whole number:
    func getRating(){
        
        var rating : Double = 0.0
        
        // Call to FB for rating and total riders/rides here
        
        if(mode == "Driver") {
            
            ref.child("users/\(ourid)/driver/rating").observeSingleEvent(of: .value, with: { snapshot in
                
                let innerRating = snapshot.value! as! NSInteger
                
                self.ref.child("users/\(self.ourid)/driver/totalRiders/").observeSingleEvent(of: .value, with: { snapshot in
                    rating = (Double) (innerRating)/(snapshot.value as! Double)
                    
                    print("our rating is \(rating)")
                    
                    if (rating >=  4.5) {
                        self.ratingImageView.image = #imageLiteral(resourceName: "fivestars")
                    } else if (rating >= 3.5) {
                        self.ratingImageView.image = #imageLiteral(resourceName: "fourstars")
                    } else if (rating >= 2.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "threestars")
                    } else if (rating >= 1.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "threestars")
                    } else if (rating >= 0.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "onestar")
                    } else {
                        // Possibly post message saying "No ratings yet"
                        self.ratingImageView.image =  #imageLiteral(resourceName: "zerostars")
                    }

                })
            })
            
        } else {
            
            ref.child("users/\(ourid)/rider/rating").observeSingleEvent(of: .value, with: { snapshot in
            
                let innerRating2 = snapshot.value! as! NSInteger
                self.ref.child("users/\(self.ourid)/rider/totalRides/").observeSingleEvent(of: .value, with: { snapshot in
                    rating = (Double) (innerRating2)/(snapshot.value as! Double)
                    print("our rating is \(rating)")
                    
                    if (rating >=  4.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "fivestars")
                    } else if (rating >= 3.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "fourstars")
                    } else if (rating >= 2.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "threestars")
                    } else if (rating >= 1.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "threestars")
                    } else if (rating >= 0.5) {
                        self.ratingImageView.image =  #imageLiteral(resourceName: "onestar")
                    } else {
                        // Possibly post message saying "No ratings yet"
                        self.ratingImageView.image =  #imageLiteral(resourceName: "zerostars")
                    }

                })
            })
        }
    }
}

extension DriverPanelViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
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
