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
import UserNotifications

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
    
    let center = UNUserNotificationCenter.current()
    
    let ref = FIRDatabase.database().reference();
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var baseDictionary: NSDictionary = [:]
    
    var riderLat : CLLocationDegrees = 0.0
    var riderLong : CLLocationDegrees = 0.0
    var riderAddress : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //user location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .automotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.createMap()
        localDelegate.DriveViewController_AD = self; //again, hoping this assignment is okay.
        localDelegate.DriveSet = true;
        localDelegate.lastState = "driver"
        
        if(localDelegate.isSwitched){
            print("loaded call to start driver map")
            localDelegate.startDriverMapObservers()
        } else {
            self.googleMap.clear()
        }
        
        
        self.ref.child("users/\(FIRAuth.auth()!.currentUser!.uid)/stateVars/driverStatus").observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.value! is String else {
                self.localDelegate.driverStatus = "request"
                if(self.localDelegate.isSwitched){
                    self.localDelegate.startDriverMapObservers()
                } else {
                    self.googleMap.clear()
                }
                return
            }
            self.localDelegate.driverStatus = snapshot.value! as! String
            
            if(self.localDelegate.isSwitched){
                self.localDelegate.startDriverMapObservers()
            } else {
                self.googleMap.clear()
            }
            return
        })
        
        
        self.ref.child("users/\(FIRAuth.auth()!.currentUser!.uid)/stateVars/offeredID").observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.value! is String else {
                self.localDelegate.offeredID = "none"
                if(self.localDelegate.isSwitched){
                    self.localDelegate.startDriverMapObservers()
                } else {
                    self.googleMap.clear()
                }
                return
            }
            self.localDelegate.offeredID = snapshot.value! as! String
            if(self.localDelegate.isSwitched){
                self.localDelegate.startDriverMapObservers()
            } else {
                self.googleMap.clear()
            }
            return
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(localDelegate.isSwitched){
            print("appearing call to start driver map")
            localDelegate.startDriverMapObservers()
        }
        
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
    
    func clearScreen() {
        self.googleMap.clear()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "driverAcceptSegue") {
            let nextVC = segue.destination as! RideSummaryTableViewController
        
            nextVC.localLat = riderLat
            nextVC.localLong = riderLong
        }
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
            panelVC.goOnlineLabel.isHidden = false
            panelVC.goOnlineSwitch.isHidden = false
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
        print("Ride offer accepted (potentially).")
        
        let ref = FIRDatabase.database().reference()
        let cellInfo: NSDictionary = item.toAnyObject() as! NSDictionary
        
        if((cellInfo["accepted"] as! NSInteger) == 1 ) {
            
                print("we have been accepted")
            
                localDelegate.driverStatus = "accepted"
                let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
            
                print("we offered a ride to: \(self.localDelegate.offeredID)")
            
                ref.child("/users/\(localDelegate.offeredID)/rider/offers/immediate").removeAllObservers()
                
                self.googleMap.clear()
                
                let marker = GMSMarker()
                let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
                let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
                ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/rider/\(localDelegate.offeredID)/origin").observe(.childChanged, with: { snapshot in
                    print("marker moving!!! \(snapshot.key)")
                    if(snapshot.key == "lat") {
                        marker.position.latitude = snapshot.value as! CLLocationDegrees
                        self.riderLat = snapshot.value as! CLLocationDegrees
                    } else {
                        marker.position.longitude = snapshot.value as! CLLocationDegrees
                        self.riderLong = snapshot.value as! CLLocationDegrees
                    }
                })
                //do any of these matter thanks to the custom display window?...
                marker.title = "Your Rider: \(cellInfo["name"])"
                marker.snippet = "Close enough to Grand Valley."
                marker.icon = GMSMarker.markerImage(with: .red)
                marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
                marker.map = self.googleMap
                
                baseDictionary = marker.userData as! NSDictionary
            
                ref.child("users/\(self.localDelegate.offeredID)/rider/accepted/immediate/").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                    print("PIN BEING DELETED")
                    marker.map = nil;
                    self.ref.child("users/\(self.localDelegate.offeredID)/rider/accepted/immediate/rider/\(self.localDelegate.offeredID)/origin").removeAllObservers()
                    
                        //if deleted here, make sure it wasnt an early cancellation.
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Ride Event"
                    
                    let baseDictionary = snapshot.value as! NSDictionary
                    
                    if(baseDictionary.value(forKey: "accepted") as! NSInteger != 1) {
                        content.body = "The ride request has been removed. You do not need to pick up this individual"
                    } else {
                        content.body = "Thank you for giving this user a ride."
                    }
                    content.sound = UNNotificationSound.default()
                    content.categoryIdentifier = "nothing_category"
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    let identifier = "ride acceptance"
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: { (error) in
                        
                        if let error = error {
                            
                            print(error.localizedDescription)
                        }
                    })
                    
                    self.localDelegate.driverStatus = "request"
                })
            
        } else {
            
            print("offer declined")
            
            //an alert about the response. and a resetting of app delegates various states.
            let content = UNMutableNotificationContent()
            content.title = "Ride Offer Response"
            content.body = "We are sorry but your ride offer was declined" //need wording help here.
            
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "nothing_category"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let identifier = "ride acceptance"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            self.center.add(request, withCompletionHandler: { (error) in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                }
            })
            
            
            localDelegate.driverStatus = "request"
            
        }
        
        return //placeholder
    }
    
    func ride_request(item: cellItem) { //someone has made a request through requests/immediate.
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
                self.ref.child("requests/immediate/\(cellInfo["uid"]!)/origin/").removeAllObservers()
        })

    }
    
    func white_ride(item: cellItem) {
        //a call to ride request even when the phone is closed i guess?... or the map only shows that one
        //rider pin?
        
        //make a pin and an observer that watches for changes to that pin to specifically watch? for updates?...
        
        // cant seem to make the marker a different color to make it stand out more...
        
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
        
        marker.title = "Potential Rider: \(cellInfo["name"])"
        marker.snippet = "Wants a ride to: (ADDRESS HERE) for $(money here)."
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
        marker.map = self.googleMap
        
        
        ref.child("requests/immediate/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
            print("PIN BEING DELETED")
            marker.map = nil;
            self.ref.child("requests/immediate/\(cellInfo["uid"]!)/origin/").removeAllObservers()
        })
    }
    
    // Google Maps functions
    
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
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
        localDelegate.changeDriverStatus(status: "offer")
        localDelegate.offeredID = baseDictionary.value(forKey: "uid")! as! String
        print("Accept Tapped but it is really an offer.")
        
        let ref = FIRDatabase.database().reference().child("users/\(baseDictionary.value(forKey: "uid")!)/rider/offers/immediate/")
        
        let user = FIRAuth.auth()!.currentUser!
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.value != nil) { //i think the origin base dictionary usage here is the cause of the pins starting in the wrong placees. try experimenting with just putting in our own lats and longs later.
                ref.child("\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": self.localDelegate.getVenmoID(), "origin": self.baseDictionary.value(forKey: "origin"), "destination": self.baseDictionary.value(forKey: "destination"), "rate": self.baseDictionary.value(forKey: "rate"), "accepted" : 0, "repeats": "none", "duration": "none"]) //value set needs to be all of our info for the snapshot.
            
                print("ride offered") //this one is if you hit the snooze button
            
            //self.googleMap.clear() //clears the map of all pins so w can show only what we care about.
            
            //make the pin with only the riders info.
            //make tracker observers etc from only the baseDictionaries uid etc?...
            
                self.performSegue(withIdentifier: "driverAcceptsSegue", sender: self)
            } else {
                //make an alert saying no offer there?
                
                let alert = UIAlertController(title: "Apologies", message: "But this rider is no longer looking for offers.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                    (action) in print("No offer")}))
            }
        })
        
        //maybe venmo id is a global var in app delegate with a getter/setter for moments like this.
        
        
        //self.googleMap.clear() //clears the map of all pins so w can show only what we care about.
        
        //make the pin with only the riders info.
        //make tracker observers etc from only the baseDictionaries uid etc?...
        
        self.performSegue(withIdentifier: "driverAcceptsSegue", sender: self)
        infoWindow.removeFromSuperview()
    }
    
    func declineTapped(button: UIButton) -> Void {
        print("Decline Tapped")
        infoWindow.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "driverAcceptsSegue" {
            if let nextVC = segue.destination as? RideSummaryTableViewController {
                // Set the attributes in the next VC.
                nextVC.informationDictionary = self.baseDictionary
                nextVC.paymentText = "Request Payment"
                nextVC.localAddress = riderAddress as String
                nextVC.localLat = riderLat
                nextVC.localLong = riderLong 
            }
            
        }
    }
    
    func fillWithAcceptance(item: cellItem) {
        let cellInfo = item.toAnyObject() as! NSDictionary
        
        if((cellInfo["uid"]! as! NSString) as String == userID) {
            print("ignoring marker")
        } else {
            let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
            
            let marker = GMSMarker()
            let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
            let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            marker.title = "Rider: \(cellInfo["name"])"
            marker.map = self.googleMap
            
            print("in acceptance, we are watching: \(cellInfo["uid"]!)")
            
            self.ref.child("users/\(cellInfo["uid"]!)/rider/accepted/immediate/rider/\(cellInfo["uid"]!)/origin").observe( .childChanged, with: { snapshot in
                if(snapshot.key == "lat") {
                    marker.position.latitude = snapshot.value as! CLLocationDegrees
                    self.riderLat = snapshot.value as! CLLocationDegrees
                } else if (snapshot.key == "long"){
                    marker.position.longitude = snapshot.value as! CLLocationDegrees
                    self.riderLong = snapshot.value as! CLLocationDegrees
                }  else {
                    self.riderAddress = snapshot.value as! NSString
                }
            }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
            //once we accept the offer, we will need a .value to get each key to remove each observer before we delete the whole section.
            
            ref.child("users/\(cellInfo["uid"]!)/rider/accepted/immediate/rider/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                print("PIN BEING DELETED")
                marker.map = nil;
                self.ref.child("users/\(cellInfo["uid"]!)/rider/accepted/immediate/rider/\(cellInfo["uid"]!)/origin").removeAllObservers()
            })
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
