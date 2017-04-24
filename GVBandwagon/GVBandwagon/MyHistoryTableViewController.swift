//
//  MyHistoryTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//
//  By using a tutorial and its start up materials as a guide for certain 
//  portions of our project, we must attach this copyright notice within our project.


/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import UIKit
import Firebase

class MyHistoryTableViewController: UITableViewController {

    @IBOutlet var doneButton: UIBarButtonItem!
    
    let ref = FIRDatabase.database().reference()
    let ourId = FIRAuth.auth()!.currentUser!.uid
    
    var ourHistory: [cellItem] = []
    var testDictionary : [String : cellItem] = [:]
    var dictionaryKeys : [String] = []
    
    var toShare: [cellItem] = []
    
    override func viewDidLoad() {
        //testDictionary["filler"] = cellItem
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        ref.child("users/\(ourId)/history/").observeSingleEvent(of: .value, with: { snapshot in
            for item in snapshot.children {
                
                print("item keys: \((item as! FIRDataSnapshot).key)")
                
                
                self.testDictionary[(item as! FIRDataSnapshot).key] = cellItem.init(snapshot: item as! FIRDataSnapshot)
                
                    //this is not going to work with destination names etc. need to go deeper with the item.key??? and then use that for an inner search that makes the cell item and appends that cell item to our history array?... a dictionary of destinations and cell items perhaps?...
            }
            self.dictionaryKeys = [String](self.testDictionary.keys.sorted()) //make an array out of all the keys so they can be used for accesses.
            print(self.dictionaryKeys.description)
            
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testDictionary.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        print("keys as we make the cells \(dictionaryKeys[indexPath.row])" )
        let cellItem = testDictionary[dictionaryKeys[indexPath.row]] //ourHistory[indexPath.row]
        
        // Configure the cell...
        print("destination Name \((cellItem?.destinationName as String?))")
        print("Names and Rate \(cellItem?.driverName as String?) \(cellItem?.riderName as String?) \(cellItem!.rate)")
        //cell.textLabel?.text = "Driver: \(cellItem!.driverName) " + "\nRider: \(cellItem!.riderName)" + " - ($\(cellItem!.rate))"
        cell.textLabel?.text = cellItem!.date as String
        cell.detailTextLabel?.text = (cellItem?.destinationName as String?); //uid shows destination and
        //time of trip but it gets cut off because the screen isnt wide enough. anyway to force
        //text wrapping/newlines in storyboard?
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destination is historySummaryViewController {
            print("within the if")
            if( toShare.count > 0){
                print("sharing the dictionary")
                (segue.destination as! historySummaryViewController).informationDictionary = toShare[0].toAnyObject() as! NSDictionary
            }
        }
    }

    
    @IBAction func onDoneTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Not sure where the pay now and request payment buttons will go, but we can still add the code here. When we decide on placement of the elements, we will copy this into the IBAction function for those buttons.
    func payNow() -> Void {
        
    }
    
    func requestPayment() -> Void {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("appending item")
        print(testDictionary[dictionaryKeys[indexPath.row]]!)
        toShare.append(testDictionary[dictionaryKeys[indexPath.row]]!)
        print(toShare.count)
        self.performSegue(withIdentifier: "toHistoryDetail", sender: self)
    }
}
