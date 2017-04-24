//
//  historySummaryViewController.swift
//  GVBandwagon
//
//  Created by Blaze on 4/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GooglePlaces
import FirebaseStorage

class historySummaryViewController: UITableViewController {
    
    let storage = FIRStorage.storage()
    
    let DATE = 0
    let DESTINATION = 1
    let ORIGIN = 2
    let NAME = 3
    

    @IBOutlet var driverTextField: UITextField!
    @IBOutlet var riderTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var destTextField: UITextField!
    @IBOutlet var originTextField: UITextField!
    
    var informationDictionary: NSDictionary = [:]
    
    var mode = "none"
    
    let ref = FIRDatabase.database().reference()
    
    var localLat : CLLocationDegrees = 0.0
    var localLong :  CLLocationDegrees = 0.0
    
    var localAddress : String = ""
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        print("We are now in the history summary")
        
        if(informationDictionary.count > 0 ) {
        
            //TODO figure out what is happening to the information dictionary in the pass over
            //so that we can actually pull it apart and use it for label/field set up.
            
            print("We are setting up the history summary")
            print(informationDictionary)
            
            print("our uid: \(informationDictionary.value(forKey: "uid")!)")
            //pull information down fresh/correctly from firebase.
            
            //rateLabel.text = "\(informationDictionary.value(forKey: "rate")!)"
            
            self.driverTextField.text = informationDictionary.value(forKey: "driverName") as! String?
            self.riderTextField.text = informationDictionary.value(forKey: "riderName") as! String?
            
            self.dateTextField.text = informationDictionary.value(forKey: "date") as! String?
            
            ref.child("users/\(informationDictionary.value(forKey: "uid")!)/phone").observeSingleEvent(of: .value, with: { snapshot in
                print("our phone: \(snapshot.value! as? NSString)")
                //self.phoneLabel.text = "\((snapshot.value! as? NSString)!)"
            })
            
            print("address \(localAddress)")
            let originDict = informationDictionary.value(forKey: "origin") as! NSDictionary
            let originText = originDict.value(forKey: "address") as! String!
            originTextField.text = originText?.components(separatedBy: ", ").joined(separator: "\n")
            
            let destText = informationDictionary.value(forKey: "destinationName") as! String?
            destTextField.text = destText?.components(separatedBy: ", ").joined(separator: "\n")
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section) == ORIGIN || (indexPath.section) == DESTINATION {
            return 100
        } else {
            return 50
        }
    }
    
    /*
     override func numberOfSections(in tableView: UITableView) -> Int {
     return 5
     }
     */
    
    /*
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     if (section == 1) {
     if (self.paymentText == "Request Payment") {
     return 3
     } else {
     return 4
     }
     } else if (section == 6) {
     return 2
     } else {
     return 1
     }
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
    
    @IBAction func onVehicleDataTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toVehicleDataSegue", sender: self)
    }
    
}
