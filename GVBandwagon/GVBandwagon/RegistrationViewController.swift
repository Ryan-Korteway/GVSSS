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

    @IBOutlet var fullNameLabel: UIView!
    @IBOutlet var phoneLabel: UIView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var fNameField: UITextField!
    @IBOutlet var lNameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var registerButton: UIButton!
   
    var currentUser : FIRUser?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = FIRAuth.auth()?.currentUser
        
        self.emailField.text = currentUser?.email
        
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
            self.ref.child("users/\(self.currentUser!.uid)/location").setValue("start")
            self.ref.child("users/\(self.currentUser!.uid)/destination").setValue("stop")
        
            self.ref.child("users/\(self.currentUser!.uid)/driver/rider_found").setValue(false)
            //self.ref.child("users/\(self.currentUser!.uid)/rider_UIDs").setValue() //rider_UID's should be added and removed as riders sign up to use the driver as their ride to the destination.
            self.ref.child("users/\(self.currentUser!.uid)/driver/total_riders").setValue(0) //gets incremented by one for each rider the driver drives.
            self.ref.child("users/\(self.currentUser!.uid)/driver/rider_score").setValue(0) //gets incremented by value from rider, 1-5 for each ride the driver gives.
        
            self.ref.child("users/\(self.currentUser!.uid)/rider/driver_found").setValue(false)
            self.ref.child("users/\(self.currentUser!.uid)/rider/driver_UID").setValue("none")
            
            // Obviously will need to check fields are formatted correctly
            // and data successfully transferred before segue.
        self.performSegue(withIdentifier: "toContainer", sender: self)
            
            }) { (error) in
                print("Update Error, \(error.localizedDescription)")
        }
    }
    
}
