//
//  RideEditTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 4/24/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class RideEditTableViewController: UITableViewController {

    @IBOutlet var destTextField: UITextField!
    @IBOutlet var originTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var freqLabel: UILabel!
    @IBOutlet var offerTextField: UITextField!
    @IBOutlet var cancelButton: UIButton!
    
    var dict: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let originDict = dict?.value(forKey: "origin") as! NSDictionary
        
        self.originTextField.text = originDict.value(forKey: "address") as? String
        self.destTextField.text = self.dict?.value(forKey: "destinationName") as? String
        self.dateTextField.text = self.dict?.value(forKey: "date") as? String
        self.freqLabel.text = self.dict?.value(forKey: "repeats") as? String
        
        // Get rate:
        let rate = self.dict?.value(forKey: "rate") as? NSNumber
        let rateString = String(describing: rate!)
        self.offerTextField.text = rateString
    }

    @IBAction func cancelTapped(_ sender: Any) {
        // Cancel ride
    }
    
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */

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
