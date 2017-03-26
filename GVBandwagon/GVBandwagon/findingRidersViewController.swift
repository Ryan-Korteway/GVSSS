//
//  findingRidersViewController.swift
//  GVBandwagon
//
//  Created by Blaze on 2/18/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import Foundation
import Firebase

class findingRidersViewController: UIViewController {
    
    
    //do we use this class at all anymore? its totally unnecessary looking...
    
    let currentUser = FIRAuth.auth()!.currentUser
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        
        let driverRef = FIRDatabase.database().reference(withPath: "users/\(currentUser!.uid)/driver/")
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
                            }
                            
                            let noAction = UIAlertAction(title:"No", style:.default) { action -> Void in
                                //code for the action can go here. so accepts or deny's
                            }
                            
                            alert.addAction(yesAction)
                            alert.addAction(noAction)
                            self.present(alert, animated:true, completion:nil)
                            
                        })
                        
                    })
                }
            }
        })
    }
    
}
