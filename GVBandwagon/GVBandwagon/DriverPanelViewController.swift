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

    @IBOutlet var goOnlineSwitch: UISwitch!
    
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
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if mySwitch.isOn {
            appDelegate.toggleRightDrawer(sender: mySwitch, animated: true)
            let centerVC = appDelegate.centerViewController as? UITabBarController
            let driveVC = centerVC?.childViewControllers[0] as? DriveViewController
            driveVC?.goOnlineLabelBtnTapped(mySwitch)

            
            ref.child("/activedrivers/\(ourid)").setValue(["name": FIRAuth.auth()!.currentUser!.displayName! as NSString,
                                                           "uid": ourid, "venmoID": localDelegate.getVenmoID(), "origin": ["lat": ourlat, "long": ourlong],
                                                        "destination": ["lat": "none", "long": "none"],
                                                           "rate" : 0, "accepted": 0, "repeats": 0, "duration": "none"]) //need protections of if destination is none, dont make a pin.
        
            localDelegate.changeMode(mode: "driver")
            localDelegate.startTimer()
        } else {
            // Remove driver from active driver list
            ref.child("/activedrivers/\(ourid)").removeValue();
            localDelegate.changeMode(mode: "rider")
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
