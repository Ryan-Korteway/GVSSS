//
//  RegistrationViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/28/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {

    // Rider fields
    @IBOutlet var fullNameLabel: UIView!
    @IBOutlet var phoneLabel: UIView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var fNameField: UITextField!
    @IBOutlet var lNameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var registerButton: UIButton!
    
    // Driver fields
    @IBOutlet var venmoLabel: UILabel!
    @IBOutlet var makeLabel: UILabel!
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var photoLabel: UILabel!
    @IBOutlet var venmoField: UITextField!
    @IBOutlet var makeField: UITextField!
    @IBOutlet var modelField: UITextField!
    @IBOutlet var vehicleImageView: UIImageView!
    
    var registeringAs = "Rider"
   
    var currentUser : FIRUser?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = FIRAuth.auth()?.currentUser
        
        self.emailField.text = currentUser?.email
        
        if (self.registeringAs == "Rider") {
            self.venmoLabel.isHidden = true
            self.makeLabel.isHidden = true
            self.modelLabel.isHidden = true
            self.photoLabel.isHidden = true
            self.venmoField.isHidden = true
            self.makeField.isHidden = true
            self.modelField.isHidden = true
            self.vehicleImageView.isHidden = true
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    @IBAction func onRegisterTap(_ sender: Any) {
        
        //leaving out the latitude and longitude fields since they are sprint two, location and destination fields need a spot to be updated in the accounts page in the future.
        
        self.ref.child("userStates").child("\(self.currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.ref.child("users/\(self.currentUser!.uid)/name").setValue(self.fNameField.text! + " " + self.lNameField.text!)
            self.ref.child("users/\(self.currentUser!.uid)/phone").setValue(self.phoneField.text)
            self.ref.child("users/\(self.currentUser!.uid)/driver/rider_found").setValue(false)
            //self.ref.child("users/\(self.currentUser!.uid)/rider_UIDs").setValue() //rider_UID's should be added and removed as riders sign up to use the driver as their ride to the destination.
            self.ref.child("users/\(self.currentUser!.uid)/driver/total_riders").setValue(0) //gets incremented by one for each rider the driver drives.
            self.ref.child("users/\(self.currentUser!.uid)/driver/rider_score").setValue(0) //gets incremented by value from rider, 1-5 for each ride the driver gives.
        
            self.ref.child("users/\(self.currentUser!.uid)/rider/driver_found").setValue(false)
            self.ref.child("users/\(self.currentUser!.uid)/rider/driver_UID").setValue("none")
            
            // Obviously will need to check fields are formatted correctly
            // and data successfully transferred before segue.
          
            // Load up the drawer from AppDelegate:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.initiateDrawer()
            appDelegate.setUpOpenObservers()
            
        //self.performSegue(withIdentifier: "toContainer", sender: self)
            
            }) { (error) in
                print("Update Error, \(error.localizedDescription)")
        }
    }
    
}
