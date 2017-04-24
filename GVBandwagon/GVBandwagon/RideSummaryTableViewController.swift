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
import FirebaseStorage

class RideSummaryTableViewController: UITableViewController {
    
    let storage = FIRStorage.storage()
    
    let PROFILE_IMAGE = 0
    let USER = 1
    let ORIGIN = 2
    let DESTINATION = 3
    let RATE = 4
    let RATE_USER = 5
    let COMPLETE_RIDE = 6
    let BUTTONS = 7

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var originStreetLabel: UILabel!
    @IBOutlet var destStreetLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var paymentButton: UIButton!
    @IBOutlet var cancelRideButton: UIButton!
    @IBOutlet var completeRideButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var vehicleDataLabel: UILabel!
    @IBOutlet weak var rateUserLabel: UILabel!
    
    var vehicleImage = UIImage()
    
    var paymentText = "Request Payment"
    var informationDictionary: NSDictionary = [:]
    
    var mode = "none"
    var immediateRideAccepted = false
    
    let ref = FIRDatabase.database().reference()
    
    var localLat : CLLocationDegrees = 0.0
    
    var localLong :  CLLocationDegrees = 0.0
    
    var localAddress : String = ""
    
    // For the buttons
    var shadowLayer: CAShapeLayer!
    var paymentShadowLayer: CAShapeLayer!
    var completeShadowLayer: CAShapeLayer!
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        self.paymentButton.setTitle(paymentText, for: .normal)
        self.configureButtons()
        self.configureProfileImage()
        
        if (self.paymentText == "Request Payment") {
            self.vehicleDataLabel.alpha = 0
            self.rateUserLabel.text = "Rate Your Rider!"
        }
        
        // If this is a summary for the driver:
        // name and rating are of Rider
        // button says "Request Payment"
        
        // If this is a summary for the rider:
        // name and rating are of Driver
        // button says "Send Payment"

        // Need to pull and fill all information from firebase. Use self.paymentText for check if here from Ride or Drive.
        // We can use UID of driver/rider in the users profile to pull the appropriate information for this view controller.
        
        if(informationDictionary.count > 0 ) {
        
            print("our uid: \(informationDictionary.value(forKey: "uid")!)")
            //pull information down fresh/correctly from firebase.
            
            rateLabel.text = "\(informationDictionary.value(forKey: "rate")!)"
            
            // Get driver/rider specific information:
            self.getUserData()
            
            // Origin address
            print("address \(localAddress)")
            let originDict = informationDictionary.value(forKey: "origin") as! NSDictionary
            originStreetLabel.text = originDict.value(forKey: "address") as! String!
            
            // Dest address
            destStreetLabel.text = informationDictionary.value(forKey: "destinationName") as! String?
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getUserData() {
        
        if (self.immediateRideAccepted) {
        
            if(paymentText == "Request Payment") {
                // Driver's side so pull riders ratings
                ref.child("users/\(informationDictionary.value(forKey: "uid")!)/rider/rating").observeSingleEvent(of: .value, with: { snapshot in
                    self.ratingLabel.text = "\((snapshot.value! as? NSInteger)!)"
                })
                self.nameLabel.text = informationDictionary.value(forKey: "riderName") as! String?
            } else {
                // Rider's side so pull drivers ratings
                ref.child("users/\(informationDictionary.value(forKey: "uid")!)/driver/rating").observeSingleEvent(of: .value, with: { snapshot in
                    self.ratingLabel.text = "\((snapshot.value! as? NSInteger)!)"
                })
                self.nameLabel.text = informationDictionary.value(forKey: "driverName") as! String?
            }
            
            // Phone number
            ref.child("users/\(informationDictionary.value(forKey: "uid")!)/phone").observeSingleEvent(of: .value, with: { snapshot in
                print("our phone: \(snapshot.value! as? NSString)")
                self.phoneLabel.text = "\((snapshot.value! as? NSString)!)"
            })
        } else {
            self.nameLabel.text = "Nobody yet!"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == USER {
            if paymentText == "Request Payment" {
                return "Rider"
            } else {
                return "Driver"
            }
        } else if section == ORIGIN {
            return "Origin"
        } else if section == DESTINATION {
            return "Destination"
        } else if section == RATE
        {
            return "Rate"
        } else {
            return ""
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toVehicleDataSegue") {
            if let vehicleDataVC = segue.destination as? VehicleDataTableViewController {
                vehicleDataVC.vehicleImage = self.vehicleImage
            }
        }
    }
    
    @IBAction func onPaymentTapped(_ sender: Any) {
        
        // Determine whether rider clicked this or driver clicked this:
        if (self.paymentText == "Submit Payment") {
            
            // Rider clicked this
            payDriver()
            
        } else {
            
            // Driver clicked this
            
        }
    }
    
    @IBAction func completeRideButton(_ sender: UIButton) {
        if(informationDictionary.count > 0 ){
            let ourID = FIRAuth.auth()!.currentUser!.uid
            ref.child("users/\(ourID)/history/\(informationDictionary.value(forKey: "destinationName")!)\(informationDictionary.value(forKey: "date"))/").setValue(informationDictionary) //this does make duplicates at the moment.
            
            if(paymentText == "Request Payment"){ //driver side.
                //set our accepted value to 0 and then delete our branch before removing the whole offer.
                let uid = FIRAuth.auth()!.currentUser!.uid
                ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/\(uid)/accepted/").setValue(1);
                sleep(1);
                ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/").removeValue()
                ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/").removeValue()
                localDelegate.driverStatus = "request"
                localDelegate.timer.invalidate()
            } else {
                //set our accepted value to 0 and then delete our branch before removing the whole offer.
                let uid = FIRAuth.auth()!.currentUser!.uid
                ref.child("users/\(uid)/rider/offers/accepted/immediate/rider/\(uid)/accepted/").setValue(1);
                sleep(1);
                ref.child("users/\(uid)/rider/offers/accepted/immediate/rider/").removeValue()
                ref.child("users/\(uid)/rider/offers/accepted/immediate/").removeValue()
                self.localDelegate.driverStatus = "request"
                self.localDelegate.offeredID = "none"
                self.localDelegate.timer.invalidate()
            }
        }
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        
        // Cancel ride
        
        if(paymentText == "Request Payment"){ //driver side.
            //set our accepted value to 0 and then delete our branch before removing the whole offer.
            let uid = FIRAuth.auth()!.currentUser!.uid
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/\(uid)/accepted/").setValue(0);
            sleep(1);
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/").removeValue()
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/").removeValue()
            localDelegate.driverStatus = "request"
            localDelegate.timer.invalidate()
        } else {
            //set our accepted value to 0 and then delete our branch before removing the whole offer.
            let uid = FIRAuth.auth()!.currentUser!.uid
            ref.child("users/\(uid)/rider/offers/accepted/immediate/rider/\(uid)/accepted/").setValue(0);
            sleep(1);
            ref.child("users/\(uid)/rider/offers/accepted/immediate/rider/").removeValue()
            ref.child("users/\(uid)/rider/offers/accepted/immediate/").removeValue()
            self.localDelegate.driverStatus = "request"
            self.localDelegate.offeredID = "none"
            self.localDelegate.timer.invalidate()
        }
        
    }
    
    
    func payDriver() {
        
        UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@\(self.informationDictionary.value(forKey: "venmoID"))&amount=\(self.informationDictionary.value(forKey: "rate"))&note=GVB") as! URL, options: [:], completionHandler: nil)
        
    }
    
    func configureButtons() {
        // Custom button design. We should put this in its own class later.
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: self.cancelRideButton.bounds, cornerRadius: 5).cgPath
            shadowLayer.fillColor = UIColor.red.cgColor
            
            self.cancelRideButton.layer.insertSublayer(shadowLayer, at: 0)
            
            self.cancelRideButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        // Payment Button
        if paymentShadowLayer == nil {
            paymentShadowLayer = CAShapeLayer()
            paymentShadowLayer.path = UIBezierPath(roundedRect: self.paymentButton.bounds, cornerRadius: 5).cgPath
            paymentShadowLayer.fillColor = UIColor.blue.cgColor
            
            self.paymentButton.layer.insertSublayer(paymentShadowLayer, at: 0)
            
            self.paymentButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        // Complete Ride Button
        if completeShadowLayer == nil {
            completeShadowLayer = CAShapeLayer()
            completeShadowLayer.path = UIBezierPath(roundedRect: self.completeRideButton.bounds, cornerRadius: 5).cgPath
            completeShadowLayer.fillColor = UIColor.blue.cgColor
            
            self.completeRideButton.layer.insertSublayer(self.completeShadowLayer, at: 0)
            
            self.completeRideButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func configureProfileImage() {
        self.profileImageView.layer.borderWidth = 3.0
        self.profileImageView.image = #imageLiteral(resourceName: "defaultUserPhoto")
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        // Get image from FB if it exists:
        self.getProfilePicFromFB()
    }
    
    func getProfilePicFromFB() {
        
        // Will get driver or riders UID and store here depending who's watching this VC:
        var otherUsersID: String?
        
        // This is drivers view, pull riders UID:
        if (self.paymentText == "Request Payment") {
            self.ref.child("users/\(informationDictionary.value(forKey: "uid")!)/rider/driver/uid").observeSingleEvent(of: .value, with: { snapshot in
                //self.ratingLabel.text = "\((snapshot.value! as? NSInteger)!)"
                otherUsersID = snapshot.value as? String
                self.setImages(otherUID: otherUsersID!)
            })
            
        } else {
            // If rider's side pull drivers UID
            self.ref.child("users/\(informationDictionary.value(forKey: "uid")!)/rider/offers/accepted/immediate/driver").observeSingleEvent(of: .value, with: { snapshot in
                for item in snapshot.children {
                    if let child = item as? FIRDataSnapshot {
                        print("snapshot child was a FIRDataSnapshot")
                        otherUsersID = child.key
                        print("Child key: \(child.key)")
                        self.setImages(otherUID: otherUsersID!)
                    }
                }
            })
        }
        
    }
    
    func setImages(otherUID: String) {
        // Image references
        let storageRef = storage.reference()
        
        // Create a reference to 'images/profilepic.jpg'
        let profileImageRef = storageRef.child("images/\(otherUID)/profilepic.jpg")
        let vehicleImageRef = storageRef.child("images/\(otherUID)/vehiclepic.jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            } else {
                // Data for "images/profilepic.jpg" is returned
                let image = UIImage(data: data!)
                self.profileImageView.image = image
                
            }
        }
        
        vehicleImageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            } else {
                let image = UIImage(data: data!)
                self.vehicleImage = image!
            }
        }
    }
    
    @IBAction func onVehicleDataTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toVehicleDataSegue", sender: self)
    }
    
}
