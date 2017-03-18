//
//  CustomKGDrawerViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 2/27/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import KGFloatingDrawer
import Firebase

class CustomKGDrawerViewController: KGDrawerViewController {
    
    // Find a way to get this in viewDidLoad?
    
    // Get a reference to the storage service using the default Firebase App
    let storage = FIRStorage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KGViewController in viewDidLoad")
        
        let userID = FIRAuth.auth()!.currentUser!.uid

        // Image references
        let storageRef = storage.reference()
        
        // Create a reference to 'images/profilepic.jpg'
        let profileImageRef = storageRef.child("images/\(userID)/profilepic.jpg")
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("KGViewController in viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("KGViewController in viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("KGViewController in viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("KGViewController in viewDidDisappear")
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
