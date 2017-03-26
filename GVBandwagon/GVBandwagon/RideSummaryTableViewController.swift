//
//  RideSummaryTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/17/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

class RideSummaryTableViewController: UITableViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var originStreetLabel: UILabel!
    @IBOutlet var originCityLabel: UILabel! //unused, all on one line
    
    @IBOutlet var destStreetLabel: UILabel!
    @IBOutlet var destCityLabel: UILabel! //unused, all on one line

    @IBOutlet var paymentButton: UIButton!

    var paymentText = "Request Payment"
    var informationDictionary: NSDictionary = [:]
    
    var mode = "none"
    
    let ref = FIRDatabase.database().reference()
    
    var localLat : CLLocationDegrees = 0.0
    
    var localLong :  CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        self.paymentButton.setTitle(paymentText, for: .normal)
        //UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@michael-christensen-20&amount=3&note=GVB") as! URL, options: [:], completionHandler: nil)
        
            // PAYMENT CODE AFTER GETTING THE RATE AND VENMO ID OF THE DRIVER ETC.
            // MIGHT JUST DO A SINGLE OBSERVE ON THE USERS RIDER
        
        // If this is a summary for the driver:
        // name and rating are of Rider
        // button says "Request Payment"
        
        // If this is a summary for the rider:
        // name and rating are of Driver
        // button says "Send Payment"

        // Need to pull and fill all information from firebase. Use self.paymentText for check if here from Ride or Drive.
        // We can use UID of driver/rider in the users profile to pull the appropriate information for this view controller.
        
        if(informationDictionary.count > 0 ) {
            nameLabel.text = informationDictionary.value(forKey: "name") as! String?
            rateLabel.text = "\(informationDictionary.value(forKey: "rate"))"
            
            if(paymentText == "Request Payment") {
                //driver side so pull riders ratings
                ref.child("users/\(informationDictionary.value(forKey: "uid"))/rider/rating").observeSingleEvent(of: .value, with: { snapshot in
                    self.ratingLabel.text = snapshot.value! as? String
                })
            } else {
                //riders side so pull drivers ratings
                ref.child("users/\(informationDictionary.value(forKey: "uid"))/driver/rating").observeSingleEvent(of: .value, with: { snapshot in
                    self.ratingLabel.text = snapshot.value! as? String
                })
            }
            
            ref.child("users/\(informationDictionary.value(forKey: "uid"))/phone").observeSingleEvent(of: .value, with: { snapshot in
                self.phoneLabel.text = "\(snapshot.value!)"
            })
        }
        //NEED A CALL TO TURN THE LATS AND LONGS BACK TO ADDRESSES TO THEN USE TO POPULATE THE 
        //ORIGIN AND DESTINATION LABELS!!!
        
        //originStreetLabel.text = SOME GOOGLE PLACES MAGIC USING LOCAL LAT AND LONG
        
        //destStreetLabel.text = SOME GOOGLE PLACES MAGIC USING the destination LAT AND LONG from the request/accept
        
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
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 4) {
            return 1
        } else {
            return 2
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
    
    func payDriver() {
        
        //TO DO PASS IN THE MARKERS USER DATA WHATEVER SO THAT THE VENMO ID AND RATE CAN BE PULLED OUT TO BE USED TO PAY THE DRIVER.
        
        //UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@\(venmoID)&amount=\(rate)&note=GVB") as! URL, options: [:], completionHandler: nil)
    }

}
