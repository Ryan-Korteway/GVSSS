//
//  MenuTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/28/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class MenuTableViewController: UITableViewController {

    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var profilePicImageView: UIImageView!
    
    // Get a reference to the storage service using the default Firebase App
    let storage = FIRStorage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.getProfilePicFromFB()
        
        /*
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let drawerVC = appDelegate.drawerViewController as? CustomKGDrawerViewController {
            self.profilePicImageView.image = drawerVC.profileImageArray[0]
            print("Created drawerVC correctly.")
        }
         */

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        modeLabel?.text = "Drive"
    }

    //TODO tapping drive mode should change the rider to driver mode/state in the userstates table and change the label from ride mode to drive mode if possible.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // Number and type of menu options changes depending on if in Ride or Drive mode...
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 80
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (indexPath.section == 1) {
            //enter profile
            //appDelegate.toggleLeftDrawer(sender: self.modeLabel, animated: false)
            //appDelegate.centerViewController = appDelegate.settingsNavController()
            
            let drawerVC = appDelegate.drawerViewController as? CustomKGDrawerViewController
            
            if let navVC = drawerVC?.centerViewController as? UINavigationController {
                if let rideVC = navVC.childViewControllers[0] as? FirstViewController {
                    rideVC.performSegue(withIdentifier: "toProfileSegue", sender: navVC)
                }
            } else if let tabVC = drawerVC?.centerViewController as? UITabBarController {
                if let driveVC = tabVC.childViewControllers[0].childViewControllers[0] as? DriveViewController {
                    driveVC.performSegue(withIdentifier: "toProfileSegue", sender: driveVC)
                }
            }
            
            appDelegate.toggleLeftDrawer(sender: self, animated: false)
            
        } else if (indexPath.section == 2) {
            // Change name of this cell label to "ride mode" if it's "drive mode", and vice versa
            if (self.modeLabel.text == "Drive") {
                // Needs to load the tabbarviewcontroller
                appDelegate.centerViewController = appDelegate.driveViewController()
                self.modeLabel.text = "Ride"
            } else {
                appDelegate.centerViewController = appDelegate.rideViewController()
                self.modeLabel.text = "Drive"
            }
        } else if (indexPath.section == 3) {
            //enter my trips
            appDelegate.centerViewController = appDelegate.myHistoryTableViewController()
        } else if (indexPath.section == 4) {
            // enter help
            appDelegate.centerViewController = appDelegate.helpViewController()
        } else if (indexPath.section == 5) {
            //sign out
            appDelegate.firebaseSignOut()
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getProfilePicFromFB() {
        
        // Image references
        let storageRef = storage.reference()
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        // Create a reference to 'images/profilepic.jpg'
        let profileImageRef = storageRef.child("images/\(userID)/profilepic.jpg")
        
        // TODO: Compress Images before UPLOAD!
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            } else {
                // Data for "images/profilepic.jpg" is returned
                let image = UIImage(data: data!)
                self.profilePicImageView.image = image

            }
        }
        
        // Get the user's name:
        let ref = FIRDatabase.database().reference();
        
        ref.child("users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            self.firstNameLabel.text = name
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
