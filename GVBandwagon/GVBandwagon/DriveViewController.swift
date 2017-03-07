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
import GoogleMaps

class DriveViewController: UIViewController {
    
    @IBOutlet var goOnlineLabelBtn: UILabel!
    @IBOutlet var messageDismissButton: UIButton!
    @IBOutlet var onlineMessageView: UIView!
    @IBOutlet var googleMap: GMSMapView!
    @IBOutlet var goOnlineButton: UIButton!
    
    var isMessageDisplayed = false
    
    let ref = FIRDatabase.database().reference();
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createMap()
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
    
    @IBAction func goOnlineLabelBtnTapped(_ sender: Any) {
        
        let tempRef = self.ref.child("activedrivers/\(self.userID)/");
        
        tempRef.child("jointime").setValue(NSDate().description)
        tempRef.child("location").setValue(["start": "Bing", "end": "Bong"])
        
        
        // If user is offline do this
        
        // Getting errors trying to change label text and
        // animate the view simultaneously.
        /*
        if (self.goOnlineLabelBtn.text == "Go Online!") {
            self.displayOnlineMessage()
        } else {
            self.goOnlineLabelBtn.text = "Go Online!"
        }
        */
        self.displayOnlineMessage()
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
    
    func createMap() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.googleMap.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.googleMap
    }
    
    func displayOnlineMessage() -> Void {
        var animateDirection: CGFloat = -125
        var shadowOpacity: Float = 0.6
        if (!isMessageDisplayed) {
            isMessageDisplayed = true
        } else {
            isMessageDisplayed = false
            animateDirection = 125
            shadowOpacity = 1.0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.onlineMessageView.frame = CGRect(x: self.onlineMessageView.frame.origin.x, y: self.onlineMessageView.frame.origin.y + animateDirection, width: self.onlineMessageView.frame.width, height: self.onlineMessageView.frame.height)
            
            self.view.layer.shadowOpacity = shadowOpacity
        }, completion: { (Bool) -> Void in
            // Do nothing.
            //self.goOnlineLabelBtn.text = "Go Offline"
        })
        
    }
    
    @IBAction func onDismissTapped(_ sender: Any) {
        self.displayOnlineMessage()
    }
    

}
