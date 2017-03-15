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

class DriverPanelViewController: UIViewController {

    @IBOutlet var goOnlineSwitch: UISwitch!
    
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
            
            var ourOrigin = CLLocationManager.coordinate //hopefully our origin is in something easy to convert to our dictionary.
            
            print(ourOrigin)
            
            ref.child("/activedrivers/\(ourid)").setValue(["name": FIRAuth.auth()!.currentUser!.displayName!, "uid": ourid, "venmoID": AppDelegate.getVenmoID(), "origin": ourOrigin, "destination": ["lat": "none", "long": "none"], "rate" : 0, "accepted": 0, "repeats": 0, "duration": "none"]) //need protections of if destination is none, dont make a pin.
        
            AppDelegate.changeMode("driver")
            AppDelegate.startTimer()
        } else {
            // Remove driver from active driver list
            ref.child("/activedrivers/\(ourid)").removeValue();
            AppDelegate.changeMode("rider")
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
