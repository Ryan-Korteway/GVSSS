//
//  DriveViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 2/12/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class DriveViewController: UIViewController {

    @IBOutlet var exitButton: UIBarButtonItem!
    @IBOutlet var allendaleView: UIView!
    @IBOutlet var meijerView: UIView!
    @IBOutlet var downtownView: UIView!
    @IBOutlet var midwayRateField: UITextField!
    @IBOutlet var farRateField: UITextField!
    @IBOutlet var midwayLabel: UILabel!
    @IBOutlet var farLabel: UILabel!
    @IBOutlet var goOnlineButton: UIButton!
    
    var selection: String = "Null"
    
    let ref = FIRDatabase.database().reference();
    
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onExitTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            // go back to MainMenuView as the eyes of the user
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func toggleLeftDrawer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender: sender as AnyObject, animated: false)
    }
    
    
    
    // When a location is tapped, highlight it, and unhighlight the others.
    // Also change the labels for the rates to each location,
    // depending on the current location.
    @IBAction func onAllenTapped(_ sender: Any) {
        if (selection == "Allendale") {
            return
        }
        self.allendaleView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.selection = "Allendale"
        self.meijerView.backgroundColor = UIColor.clear
        self.downtownView.backgroundColor = UIColor.clear
        
        // Adjust labels
        self.midwayLabel.text = "Meijer Rate"
        self.farLabel.text = "Downtown Rate"
    }

    @IBAction func onMeijerTapped(_ sender: Any) {
        if (selection == "Meijer") {
            return
        }
        self.meijerView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.selection = "Meijer"
        self.allendaleView.backgroundColor = UIColor.clear
        self.downtownView.backgroundColor = UIColor.clear
        
        // Adjust labels
        self.midwayLabel.text = "Allendale Rate"
        self.farLabel.text = "Downtown Rate"
    }
    
    @IBAction func onDowntownTapped(_ sender: Any) {
        if (selection == "Downtown") {
            return
        }
        self.downtownView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.selection = "Downtown"
        self.meijerView.backgroundColor = UIColor.clear
        self.allendaleView.backgroundColor = UIColor.clear
        
        // Adjust labels
        self.midwayLabel.text = "Meijer Rate"
        self.farLabel.text = "Allendale Rate"
    }
    
    // TODO: Ryan, here you could send some hardcoded information to Firebase. At least when
    // the UI (Maps, etc) is finished we'll have the Firebase code prepped and ready to go.
    @IBAction func onGoOnlineTapped(_ sender: Any) {
    
        let tempRef = self.ref.child("activedrivers/\(userID)/")
        tempRef.child("jointime").setValue(NSDate().description)
        tempRef.child("location").setValue(["start": "Bing", "stop": "Bong"]) //this will be all the better once we use lats and longs that can be fetched at any time hopefully.
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
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
