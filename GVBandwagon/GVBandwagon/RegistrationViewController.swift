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
    
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = FIRAuth.auth()?.currentUser
        
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
        
        // Again hardcoded 0001 will need to change.
        self.ref.child("users/0001/name").setValue(self.fNameField.text)
        self.ref.child("users/0001/phone").setValue(self.phoneField.text)
        
        // Obviously will need to check fields are formatted correctly
        // and data successfully transferred before segue.
        self.performSegue(withIdentifier: "toContainer", sender: self)
    }
    
}
