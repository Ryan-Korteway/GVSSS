//
//  RegisterAsViewController.swift
//  GVBandwagon
//
//  Created by Blaze on 1/29/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegisterAsViewController: UIViewController {
 
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    var currentUser : FIRUser?
    
    @IBAction func RiderButton(_ sender: UIButton) {
        self.ref.child("userStates").child("\(currentUser?.uid)").setValue(false)
    }
    
    @IBAction func DriverButton(_ sender: UIButton) {
        self.ref.child("userStates").child("\(currentUser?.uid)").setValue(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FIRAuth.auth()?.currentUser
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
