//
//  userInfoTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 2/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class userInfoTableViewController: UITableViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet var fNameField: UITextField!
    @IBOutlet var lNameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var venmoField: UITextField!
    @IBOutlet var makeField: UITextField!
    @IBOutlet var colorField: UITextField!
    @IBOutlet var modelField: UITextField!
    @IBOutlet var profilePicView: UIImageView!
    @IBOutlet var vehiclePhotoImageView: UIImageView!
    
    var profileImage:UIImage? = nil
    var changingImage = "Profile"
    
    var currentUser : FIRUser?
    var userID: String?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.navigationController?.navigationBar.isHidden = false
        
        if let image = self.profileImage {
            self.profilePicView.image = image
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.currentUser = FIRAuth.auth()?.currentUser
        userID = self.currentUser?.uid
        //self.fNameField.text = currentUser?.displayName
        print("What is display name? : \(currentUser?.displayName)")
        
        self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let fname = value?["name"] as? String ?? ""
            //let user = User.init(username: username)
            let phone = value?["phone"] as? String ?? ""
            self.emailField.text = self.currentUser?.email
            
            self.fNameField.text = fname
            self.phoneField.text = phone
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 8
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 || indexPath.section == 6 || indexPath.section == 7) {
            return 100
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            
            // Open the photo library
            self.changingImage = "Profile"
            self.openPhotoLibrary()
            
        } else if (indexPath.section == 7) {
            self.changingImage = "Vehicle"
            self.openPhotoLibrary()
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
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            
            print("Updating...") //dont see why we need the observer to do the updates but okay...
            
            self.ref.child("users").child("\(self.currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.ref.child("users/\(self.currentUser!.uid)/name").setValue(self.fNameField.text! + " " + self.lNameField.text!)
                self.ref.child("users/\(self.currentUser!.uid)/phone").setValue(self.phoneField.text)
                
            }) { (error) in
                print("Update Error, \(error.localizedDescription)")
            }
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var type: String
        
        // If user is updating their proifle pic:
        if (self.changingImage == "Profile") {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profilePicView.image = image
                self.setMenuProfilePic(image: image)
            } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.profilePicView.image = image
            } else {
                self.profilePicView.image = nil
            }
            
            // TODO: Not using???
            // Capture the image path for uploading to Firebase:
            let url = info["UIImagePickerControllerReferenceURL"] as! URL
            
            type = "Profile"
            
        // If user is updating their vehicle pic:
        } else {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.vehiclePhotoImageView.image = image
            } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.vehiclePhotoImageView.image = image
            } else {
                self.vehiclePhotoImageView.image = nil
            }
            
            // Capture the image path for uploading to Firebase:
            let url = info["UIImagePickerControllerReferenceURL"] as! URL
            
            type = "Vehicle"
        }
        
        self.updatePic(info: info, type: type)
        
    }
    
    func updatePic(info: [String : Any], type: String) {
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        
        let imageUrl          = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName         = imageUrl.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath         = photoURL.appendingPathComponent(imageName!)
        let image             = info[UIImagePickerControllerOriginalImage]as! UIImage
        let data              = UIImageJPEGRepresentation(image, 0.0)
        
        
        var imageRef: FIRStorageReference
        
        // Create a reference to 'images/profilepic.jpg' or 'images/vehiclepic.jpg'
        if (type == "Profile") {
            imageRef = storageRef.child("images/\(self.userID!)/profilepic.jpg")
        } else {
            imageRef = storageRef.child("images/\(self.userID!)/vehiclepic.jpg")
        }

        print("Path from update: \(localPath?.absoluteString)")
            
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = imageRef.put(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
        }
    }
    
    func setMenuProfilePic(image: UIImage) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let leftVC = appDelegate.drawerViewController.leftViewController as? MenuTableViewController {
            leftVC.profilePicImageView.image = image
        }
    }
    
    @IBAction func onDoneTapped(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
