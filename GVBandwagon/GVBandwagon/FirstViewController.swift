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
import UserNotifications //the thing to import for local notifications.

class FirstViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var fromPickerView: UIPickerView!
    @IBOutlet var toPickerView: UIPickerView!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var signOutButton: UIBarButtonItem!
    
    var containerDelegate: ContainerDelegate? = nil
    
    //let userid = "0001" //hardcoded values, should be the fireauth current user stuff.
    let currentUser = FIRAuth.auth()!.currentUser
    let pickerData: [String] = ["Allendale", "Meijer", "Downtown"]
    
    var userFrom = "nowhere"
    var userTo = "somewhere"
    
    let ref = FIRDatabase.database().reference()
    
    var uid_forDriver = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // COPY FOR POP UP'S ABOUT RIDER DRIVER OFFERS STARTS HERE. >>>>> might be able to relocate these to "application will enter foreground" to make them app wide?!!
       
        let driverRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/driver/")
        let riderRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/rider/")
        var riderfirst = true;
        var driverfirst = true;
        
        driverRef.child("rider_found").observe(.value, with: { (snapshot) in //RIDER ACCEPTANCE MUST REMOVE DRIVERS FROM ACTIVE DRIVERS!!!
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if (driverfirst) {
                driverfirst = false;
            } else {
                    //may need to further restrict the alert so that it does not pop up when the riderfound value is being reset to false.
                
                if(snapshot.value! as! Bool) {
                    
                        driverRef.child("rider_uid").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            //let user = self.ref.child("users/\(snapshot.value!)").queryEqual(toValue: "name")
                            self.ref.child("users/\(snapshot.value!)/name").observeSingleEvent(of: .value , with: { (innerSnapshot) in
                                //ALL OF THIS WORKS OTHER THAN THE QUERY NOT BRINGING UP THE RIDERS ACTUAL NAME!!!
                                
                                let alert = UIAlertController(title:"Rider Found", message:"Would you like to give \(innerSnapshot.value!) a ride?",
                                    preferredStyle: .alert)
                                
                                let yesAction = UIAlertAction(title:"Yes", style:.default) { action -> Void in
                                    //code for the action can go here. so accepts or deny's
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_uid").setValue(self.currentUser!.uid)
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_found").setValue(true)
                                }
                                
                                let noAction = UIAlertAction(title:"No", style:.default) { action -> Void in
                                    //code for the action can go here. so accepts or deny's
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_uid").setValue("none")
                                    self.ref.child("users/\(snapshot.value!)/rider/driver_found").setValue(true)
                                }
                                
                                alert.addAction(yesAction)
                                alert.addAction(noAction)
                                self.present(alert, animated:true, completion:nil)
                                driverRef.child("rider_found").setValue(false)
                                
                            })

                        })
                }
            }
        })

        riderRef.child("driver_found").observe(.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if (riderfirst) {
                riderfirst = false;
            } else {
                //may need to further restrict the alert so that it does not pop up when the riderfound value is being reset to false.
                
                if(snapshot.value! as! Bool) {
                    riderRef.child("driver_uid").observeSingleEvent(of: .value, with: { (snapshot) in
                    //inner if for accepted, else for rejected.
                    if( snapshot.value! as! String == "none") {
                        let alert = UIAlertController(title:"Driver Alert", message:"We are sorry but this driver is unavailable.", preferredStyle: .alert);
                        
                        let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                            //code for the action can go here. so accepts or deny's
                            riderRef.child("driver_found").setValue(false)
                        }
                        
                        alert.addAction(defaultAction);
                        self.present(alert, animated:true, completion:nil);
                        
                    } else {
                        
                        let alert = UIAlertController(title:"Driver Alert", message:"The driver has accepted.", preferredStyle: .alert);
                        //maybe add a see profile action that triggers a seque to a page that pre fills itself with the drivers info based on his UID?
                        
                        let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                            //code for the action can go here. so accepts or deny's
                            riderRef.child("driver_found").setValue(false)
                        }
                        
                        alert.addAction(defaultAction);
                        self.present(alert, animated:true, completion:nil);
                    } //inner else end

                    
                }) //inner snapshot end
                
               } //outer if end
           } //outer else end
        }) //observe end        COPY STOPS HERE
        
        ref.child("users/\(currentUser!.uid)/rider/driver_uid").observe(.value, with: { (snapshot) in
                self.uid_forDriver = snapshot.value! as! String ;
        })
        
    } //end of view did load.
    
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
            userFrom = pickerData[row]
            print("Picker view selected: fromPickerView: \(pickerData[row])")
        } else {
            userTo = pickerData[row]
            print("Picker view selected: toPickerView: \(pickerData[row])")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //nameField.resignFirstResponder() // User with picker?
    }
    
    func updateUserInfo(name: String, phone: String) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        self.ref.child("users/\(userID)/name").setValue(name)
        self.ref.child("users/\(userID)/phone").setValue(phone)
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

        let userID = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("userStates").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(snapshot.value! as! Bool) {
                let tempRef = self.ref.child("activedrivers/\(userID)/")
                tempRef.removeValue()
            }
            
        })
        
        sleep(1) //one second delay needed to allow for the tempRef.removevalue to run before the sign out occurs. 

        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth!.signOut()
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
    
    @IBAction func FindDriver(_ sender: Any) { // lots of logical synchronization issues
        
        //performing a query through active drivers to get an array of all the UID's, then use the uid's to do a query to find drivers with the right location/destination and update their riders found to true and with the riders UID
        
        ref.child("activedrivers").queryOrdered(byChild: "jointime").observe(.value, with: { snapshot in
            
            for driver in snapshot.children {
                print((driver as! FIRDataSnapshot).key)
                print((driver as! FIRDataSnapshot).childSnapshot(forPath: "location").value as! NSDictionary) //this could be it for group value pull down.
                let driver_dict = (driver as! FIRDataSnapshot).childSnapshot(forPath: "location").value as! NSDictionary
                
                if ( driver_dict["start"] as! String == self.userFrom && driver_dict["stop"] as! String == self.userTo ) {
                    
                    self.ref.child("users/\((driver as! FIRDataSnapshot).key)/driver/rider_uid").setValue(self.currentUser!.uid)
                    self.ref.child("users/\((driver as! FIRDataSnapshot).key)/driver/rider_found").setValue(true)
                    
                    sleep(30) //neither sleep nor infinite wait loop will do it... ACTUALLY SHOULD WORK BETWEEN DEVICES, JUST NOT FROM ONE USER TO THE SAME USER.
                    
                    //set a timer perhaps and when it goes off in 30 seconds, trigger this pop up etc... idk still how we would wait without freezing the app...
                    
                    if (self.uid_forDriver != "none") {
                        let alert = UIAlertController(title:"Driver Alert", message:"Your Driver has been found. They are on their way.", preferredStyle: .alert);

                        let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
                        }

                        alert.addAction(defaultAction);
                        self.present(alert, animated:true, completion:nil);
                        
                        return
                    }//end if
                }
                
            }
            
            let alert = UIAlertController(title:"Driver Alert", message:"We are sorry but there are no drivers.", preferredStyle: .alert);
            
            let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
            }
            
            alert.addAction(defaultAction);
            self.present(alert, animated:true, completion:nil);
            
            return

        })
        
        print("about to leave find driver");
        
        return;
    }
    
} //end of the class/file.
