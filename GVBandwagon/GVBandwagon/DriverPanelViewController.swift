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
    
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var tripCounterLabel: UILabel!
    var totalTrips = 0
    
    var mode = "Ride"
    
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
        
        self.ratingImageView.image = getRating()
        getActiveTrip()
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
                                                           "rate" : 0, "accepted": 0, "repeats": 0, "duration": "none"]) //need protections of if destination is none, dont make a pin.
        
            localDelegate.changeMode(mode: "driver")
            localDelegate.isSwitched = true
            localDelegate.startTimer()
            localDelegate.startDriverMapObservers()
        } else {
            // Remove driver from active driver list
            ref.child("/activedrivers/\(ourid)").removeValue();
            localDelegate.changeMode(mode: "rider")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Get active trip from FB
    func getActiveTrip() {
    }
    
    // Get rating from FB. Return stars based on rounded to nearest whole number:
    func getRating() -> UIImage {
        
        var rating = 0.0
        
        // Call to FB for rating
        
        if (rating >=  4.5) {
            return #imageLiteral(resourceName: "fivestars")
        } else if (rating >= 3.5) {
            return #imageLiteral(resourceName: "fourstars")
        } else if (rating >= 2.5) {
            return #imageLiteral(resourceName: "threestars")
        } else if (rating >= 1.5) {
            return #imageLiteral(resourceName: "threestars")
        } else if (rating >= 0.5) {
            return #imageLiteral(resourceName: "onestar")
        } else {
            // Possibly post message saying "No ratings yet"
            return #imageLiteral(resourceName: "zerostars")
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
