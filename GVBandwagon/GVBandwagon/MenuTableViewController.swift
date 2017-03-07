//
//  MenuTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/28/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var containerDelegate: ContainerDelegate?

    @IBOutlet var modeLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 7
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (indexPath.section == 1) {
            //enter profile
            //appDelegate.toggleLeftDrawer(sender: self.modeLabel, animated: false)
            appDelegate.centerViewController = appDelegate.settingsNavController()
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
            //enter scheduled rides
        } else if (indexPath.section == 4) {
            //enter my trips
        } else if (indexPath.section == 5) {
            // enter help
        } else {
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
}
