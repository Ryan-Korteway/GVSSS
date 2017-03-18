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
    
    var profileImage: UIImage!
    
    // Get a reference to the storage service using the default Firebase App
    let storage = FIRStorage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KGViewController in viewDidLoad")
        
        self.profileImage = getProfilePicFromFB()
            
    }
    
    func assignProfilePic() {
        if let leftDrawer = self.leftViewController as? MenuTableViewController {
            //let image = getProfilePicFromFB()
            leftDrawer.profilePicImageView.image = self.profileImage
            print("Assigned image to profile pic in menu.")
        }
    }
    
    func getProfilePicFromFB() -> UIImage {
        
        // Image references
        let storageRef = storage.reference()
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        // Create a reference to 'images/profilepic.jpg'
        let profileImageRef = storageRef.child("images/\(userID)/profilepic.jpg")
        
        var image = UIImage()
        
        // TODO: Compress Images before UPLOAD!
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profileImageRef.data(withMaxSize: 1 * 10240 * 10240) { data, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            } else {
                // Data for "images/island.jpg" is returned
                print("Downloaded profile pic successfully.")
                image = UIImage(data: data!)!
            }
        }
        
        return image
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
