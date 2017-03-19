//
//  RequestRideViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/15/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase

class RequestRideViewController: UIViewController {

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var submitButton: UIBarButtonItem!
    
    @IBOutlet var freqSwitch: UISwitch!
    @IBOutlet var freqView: UIView!
    @IBOutlet var offerLabel: UILabel!
    @IBOutlet var dollarSignLabel: UILabel!
    @IBOutlet var offerTextField: UITextField!
    let ref = FIRDatabase.database().reference()
    let currentUser = FIRAuth.auth()!.currentUser
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var startingFrom: NSDictionary = ["lat": 43.013570, "long": -85.775875 ]
    var goingTo: NSDictionary = ["latitude": 42.013570, "longitude": -85.775875]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y, width: self.freqView.frame.width, height: 0)
        
        self.freqSwitch.setOn(false, animated: false)
        self.freqSwitch.addTarget(self, action: #selector(switchIsChanged(mySwitch:)), for: .valueChanged)
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        
        if mySwitch.isOn {
            self.animateElements(isOn: true)
        } else {
            self.animateElements(isOn: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateElements(isOn: Bool) -> Void {
        
        var newHeight: CGFloat = 0
        var newY: CGFloat = -200
        var newAlpha: CGFloat = 0
        
        if (isOn) {
            newHeight = 200
            newY = 200
            newAlpha = 1
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y, width: self.freqView.frame.width, height: newHeight)
            
            self.offerLabel.frame = CGRect(x: self.offerLabel.frame.origin.x, y: self.offerLabel.frame.origin.y + newY, width: self.offerLabel.frame.width, height: self.offerLabel.frame.height)
            self.dollarSignLabel.frame = CGRect(x: self.dollarSignLabel.frame.origin.x, y: self.dollarSignLabel.frame.origin.y + newY, width: self.dollarSignLabel.frame.width, height: self.dollarSignLabel.frame.height)
            self.offerTextField.frame = CGRect(x: self.offerTextField.frame.origin.x, y: self.offerTextField.frame.origin.y + newY, width: self.offerTextField.frame.width, height: self.offerTextField.frame.height)
            
            self.freqView.alpha = newAlpha
            
        }, completion: { (Bool) -> Void in
            // Do nothing.
        })
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        // Do something
        //all this to be moved into new view controller logic at some point.
        
        //SELF GOING TO NEED REPLACING WITH THE SEARCHING OF A DESTINATION FROM THE PAGE.
        
        let currentLat = self.localDelegate.locationManager.location!.coordinate.latitude 
        let currentLong = self.localDelegate.locationManager.location!.coordinate.longitude
        
        print("Current lat and long: \(currentLat) \(currentLong)")
        
        ref.child("requests/immediate/\(currentUser!.uid)/").setValue(["name": currentUser!.displayName!, "uid": currentUser!.uid, "venmoID": "none", "origin": ["lat": currentLat, "long": currentLong], "destination": self.goingTo, "rate" : 15, "accepted": 0, "repeats": 0, "duration": "none"]) //locations being sent here.
        
        localDelegate.startTimer();
        localDelegate.status = "offer"
        _ = self.navigationController?.popViewController(animated: true)
        
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
