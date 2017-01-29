//
//  FirstViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class FirstViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var fromPickerView: UIPickerView!
    @IBOutlet var toPickerView: UIPickerView!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var signOutButton: UIBarButtonItem!
    
    var containerDelegate: ContainerDelegate? = nil
    
    let userid = "0001"
    let pickerData: [String] = ["Allendale", "Meijer", "Downtown"]
    
    let ref = FIRDatabase.database().reference(withPath: "users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        ref.observe(.value, with: { snapshot in
            print(snapshot.value!)
        })
         */
        
        // Connect data:
        self.fromPickerView.delegate = self
        self.fromPickerView.dataSource = self
        self.toPickerView.delegate = self
        self.toPickerView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Picker view delegate functions:
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (pickerView == self.fromPickerView) {
            print("Picker view selected: fromPickerView: \(pickerData[row])")
        } else {
            print("Picker view selected: toPickerView: \(pickerData[row])")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //nameField.resignFirstResponder() // User with picker?
    }
    
    func updateUserInfo(name: String, phone: String) {
        self.ref.child("\(self.userid)/name").setValue(name)
        self.ref.child("\(self.userid)/phone").setValue(phone)
    }
    
    @IBAction func onMenuTapped(_ sender: Any) {
        guard let menuOpen = self.containerDelegate?.menuShown else {
            print("containerDelegate or it's menuShown field is nil!")
            return
        }
        if (menuOpen) {
            self.containerDelegate?.hideMenu()
        } else {
            self.containerDelegate?.showMenu()
        }
    }
    
    @IBAction func onSignOutTapped(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func onViewTapped(_ sender: Any) {
        guard let menuOpen = self.containerDelegate?.menuShown else {
            print("containerDelegate or it's menuShown field is nil!")
            return
        }
        if (menuOpen) {
            self.containerDelegate?.hideMenu()
        }
    }
    
    
}

