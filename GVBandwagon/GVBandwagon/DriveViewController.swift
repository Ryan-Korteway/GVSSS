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

class DriveViewController: UIViewController, GMSMapViewDelegate, driver_notifications {
    
    @IBOutlet var driverPanelButton: UIButton!
    @IBOutlet var displayMsgBtmCons: NSLayoutConstraint!
    @IBOutlet var messageDismissButton: UIButton!
    @IBOutlet var onlineMessageView: UIView!
    @IBOutlet var googleMap: GMSMapView!
    
    // initialize and keep a marker and a custom infowindow
    var tappedMarker = GMSMarker()
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    var isMessageDisplayed = false
    let locationManager = CLLocationManager()
    
    let ref = FIRDatabase.database().reference();
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var baseDictionary: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        //user location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .automotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.createMap()
        localDelegate.DriveViewController_AD = self; //again, hoping this assignment is okay.
        localDelegate.DriveSet = true;
        
        // Test marker
        let testMarker = GMSMarker()
        testMarker.position = CLLocationCoordinate2D(latitude: 42.973984, longitude: -85.695527)
        testMarker.icon = GMSMarker.markerImage(with: .green)
        testMarker.map = self.googleMap
        let origin = ["lat": 42.973984, "long":-85.695527]
        
        let info: NSDictionary = ["name": "Nick", "origin": origin, "destination": "Downtown", "rate": "$5"]
        
        testMarker.userData = info
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        self.googleMap.isMyLocationEnabled = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.delegate = self
    }
    
    func displayOnlineMessage() -> Void {
        
        print("isMessageDisplayed before: \(isMessageDisplayed)")
        
        var animateDirection: CGFloat = -125
        var shadowOpacity: Float = 0.6
        if (!isMessageDisplayed) {
            isMessageDisplayed = true
        } else {
            isMessageDisplayed = false
            animateDirection = 125
            shadowOpacity = 1.0
        }
        
        print("isMessageDisplayed after: \(isMessageDisplayed)")
        print("Animate direction: \(animateDirection)\n")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.onlineMessageView.frame = CGRect(x: self.onlineMessageView.frame.origin.x, y: self.onlineMessageView.frame.origin.y + animateDirection, width: self.onlineMessageView.frame.width, height: self.onlineMessageView.frame.height)
            
            self.view.layer.shadowOpacity = shadowOpacity
        }, completion: { (Bool) -> Void in
            // Do nothing.
        })
        
    }
    
    
    @IBAction func onDriverPanelTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender: sender as AnyObject, animated: false)
        if let panelVC = appDelegate.drawerViewController.rightViewController as? DriverPanelViewController {
            panelVC.mode = "Drive"
        }
    }
    
    @IBAction func onDismissTapped(_ sender: Any) {
        self.displayOnlineMessage()
    }
    
    func isRider() -> Bool {
        return false;
    }
    
    func isDriver() -> Bool {
        return true;
    }
    
    func ride_accept(item: cellItem) {
        print("Ride offer accepted.")
        
        return //placeholder
    }
    
    func ride_request(item: cellItem) {
        //make a rider icon on the drivers map
        
        //make a pin and an observer that watches for changes to that pin to specifically watch? for updates?...
        
        print("ride request being made")
        
        let cellInfo: NSDictionary = item.toAnyObject() as! NSDictionary
        let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
        //let destinationInfo: NSDictionary = cellInfo["destination"] as! NSDictionary
        
        print("our start lat and long are \(locationInfo["lat"]) and \(locationInfo["long"])")
        
        print("our start lat and long are \(locationInfo.value(forKey: "lat") as! CLLocationDegrees) \(locationInfo.value(forKey: "long") as! CLLocationDegrees)")
        
        print("our id \(cellInfo["uid"]!)")
        
        let marker = GMSMarker()
        let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
        let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        ref.child("requests/immediate/\(cellInfo["uid"]!)/origin/").observe(.childChanged, with: { snapshot in
                print("marker moving!!! \(snapshot.key)")
                if(snapshot.key == "lat") {
                    marker.position.latitude = snapshot.value as! CLLocationDegrees
                } else {
                    marker.position.longitude = snapshot.value as! CLLocationDegrees
                }
            })
        
        //marker.title = "Potential Rider: \(cellInfo["name"])"
        //marker.snippet = "Close enough to Grand Valley."
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
        marker.map = self.googleMap

        
        ref.child("requests/immediate/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                print("PIN BEING DELETED")
                marker.map = nil;
                self.ref.child("requests/immediate/\(cellInfo["uid"])/origin/").removeAllObservers()
        })
        
//        let marker2 = GMSMarker()
//        marker2.position = CLLocationCoordinate2D(latitude: destinationInfo.value(forKey: "latitude") as! CLLocationDegrees, longitude: destinationInfo.value(forKey: "longitude") as! CLLocationDegrees)
//        marker2.userData = cellInfo
//        marker2.title = "Potential Rider Destination"
//        marker2.snippet = "Close enough to Grand Valley."
//        
//        marker2.map = self.googleMap

    }
    
    func white_ride(item: cellItem) {
        //a call to ride request even when the phone is closed i guess?... or the map only shows that one
        //rider pin?
        
        //make a pin and an observer that watches for changes to that pin to specifically watch? for updates?...
        
        // cant seem to make the marker a different color to make it stand out more...
        
        let cellInfo: NSDictionary = item.toAnyObject() as! NSDictionary
        let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
        let destinationInfo: NSDictionary = cellInfo["destination"] as! NSDictionary
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locationInfo.value(forKey: "lat") as! CLLocationDegrees, longitude: locationInfo.value(forKey: "long") as! CLLocationDegrees)
        marker.title = "White Listed Rider: \(cellInfo["name"])"
        marker.snippet = "Close enough to Grand Valley."
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.map = self.googleMap
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: destinationInfo.value(forKey: "latitude") as! CLLocationDegrees, longitude: destinationInfo.value(forKey: "longitude") as! CLLocationDegrees)
        marker2.title = "Potential Rider Destination"
        marker2.snippet = "Close enough to Grand Valley."
        
        marker2.map = self.googleMap

    }
    
    // Google Maps functions
    
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        baseDictionary = marker.userData as! NSDictionary
        let locationDictionary = baseDictionary.value(forKey: "origin") as! NSDictionary
        
        let location = CLLocationCoordinate2D(latitude: locationDictionary.value(forKey: "lat") as! CLLocationDegrees, longitude: locationDictionary.value(forKey: "long") as! CLLocationDegrees)
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        infoWindow.nameLabel.text = (baseDictionary.value(forKey: "name") as! NSString) as String
        infoWindow.destLabel.text = baseDictionary.value(forKey: "destination").debugDescription
        infoWindow.rateLabel.text = "\(baseDictionary.value(forKey: "rate"))"
        
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y -= 90
        
        infoWindow.acceptButton.addTarget(self, action: #selector(acceptTapped(button:)), for: .touchUpInside)
        infoWindow.declineButton.addTarget(self, action: #selector(declineTapped(button:)), for: .touchUpInside)
        
        self.view.addSubview(infoWindow)
        
        
        // Remember to return false
        // so marker event is still handled by delegate
        return false
    }
    
    // let the custom infowindow follows the camera
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (tappedMarker.userData != nil){
            let location = CLLocationCoordinate2D(latitude: tappedMarker.position.latitude, longitude: tappedMarker.position.longitude)
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y -= 90
        }
    }
    
    // take care of the close event
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    func acceptTapped(button: UIButton) -> Void {
        localDelegate.changeStatus(status: "offer")
        print("Accept Tapped but it is really an offer.")
        
        let ref = FIRDatabase.database().reference().child("users/\(baseDictionary.value(forKey: "uid")!)/rider/offers/immediate/")
        
        let user = FIRAuth.auth()!.currentUser!
        
        //idk about user.displayName here.
        
        //maybe venmo id is a global var in app delegate with a getter/setter for moments like this.
        ref.child("\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": localDelegate.getVenmoID(), "origin": baseDictionary.value(forKey: "origin"), "destination": baseDictionary.value(forKey: "destination"), "rate": baseDictionary.value(forKey: "rate"), "accepted" : 0, "repeats": 0, "duration": "none"]) //value set needs to be all of our info for the snapshot.
        
        print("ride offered") //this one is if you hit the snooze button
        
        self.googleMap.clear() //clears the map of all pins so w can show only what w care about.
        
        //make the pin with only the riders info.
        //make tracker observers etc from only the baseDictionaries uid etc?...
        
        performSegue(withIdentifier: "driverAcceptsSegue", sender: self)
        infoWindow.removeFromSuperview()
        
        // Set Active Trip of Right Drawer to riders name and set it to clickable.
        
    }
    
    func declineTapped(button: UIButton) -> Void {
        print("Decline Tapped")
        infoWindow.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "driverAcceptsSegue" {
            if let nextVC = segue.destination as? RideSummaryTableViewController {
                // Set the attributes in the next VC.
                nextVC.paymentText = "Request Payment"
            }
        }
    }
}

extension DriveViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            self.googleMap.isMyLocationEnabled = true
            self.googleMap.settings.myLocationButton = true
        } else {
            print("\nNOT AUTHORIZED\n")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            //self.googleMap.animate(to: camera)
            self.googleMap.camera = camera
            
            locationManager.stopUpdatingLocation()
        } else {
            print("No location found!")
        }
    }
}
