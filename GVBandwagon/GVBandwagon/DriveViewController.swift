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
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100), type: "Driver", name: "Name", dest: "Destination", rate: "?")
    
    var isMessageDisplayed = false
    let locationManager = CLLocationManager()
    
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
        self.googleMap.settings.compassButton = true
        self.googleMap.delegate = self
    }
    
    func displayOnlineMessage() -> Void {
        
        var animateDirection: CGFloat = -125
        if (!isMessageDisplayed) {
            isMessageDisplayed = true
        } else {
            isMessageDisplayed = false
            animateDirection = 125
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.onlineMessageView.frame = CGRect(x: self.onlineMessageView.frame.origin.x, y: self.onlineMessageView.frame.origin.y + animateDirection, width: self.onlineMessageView.frame.width, height: self.onlineMessageView.frame.height)
            
        }, completion: { (Bool) -> Void in
            // Do nothing.
        })
    }
    
    
    @IBAction func onDriverPanelTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender: sender as AnyObject, animated: false)
        if let panelVC = appDelegate.drawerViewController.rightViewController as? DriverPanelViewController {
            panelVC.mode = "Driver"
            panelVC.goOnlineLabel.isHidden = false
            panelVC.goOnlineSwitch.isHidden = false
            panelVC.getRating()
            
            // Reposition contents to revel space where "Go Online" switch is:
            // Notice the hard-coded 220:
            
            //panelVC.contentsView.frame = panelVC.contentsView.frame.offsetBy(dx: 0, dy: -60)
            panelVC.contentsView.frame = CGRect(x: panelVC.contentsView.frame.origin.x, y: 220, width: panelVC.contentsView.frame.width, height: panelVC.contentsView.frame.height)
            
            panelVC.scheduledRidesTableVC?.getFutureRides()
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
                print("we offered a ride to: \(self.localDelegate.offeredID)")
 
                ref.child("/users/\(localDelegate.offeredID)/rider/offers/immediate").removeAllObservers()
            
                self.googleMap.clear()
            
                localDelegate.startDriverMapObservers()
            
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
            self.localDelegate.center.add(request, withCompletionHandler: { (error) in
                
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
        //cellInfo["uid"] = "myUID" //to comment out later.
        
        let marker = GMSMarker()
        let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
        let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        ref.child("requests/immediate/\(cellInfo["uid"]!)/origin/").observe(.childChanged, with: { snapshot in
                print("marker moving!!! \(snapshot.key)")
                if(snapshot.key == "lat") {
                    marker.position.latitude = snapshot.value as! CLLocationDegrees
                } else if(snapshot.key == "long") {
                    marker.position.longitude = snapshot.value as! CLLocationDegrees
                }
            })
        
        //marker.title = "Potential Rider: \(cellInfo["name"])"
        //marker.snippet = "Close enough to Grand Valley."
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
        marker.map = self.googleMap

        //baseDictionary = marker.userData as! NSDictionary
        
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
            } else if(snapshot.key == "long") {
                marker.position.longitude = snapshot.value as! CLLocationDegrees
            }
        })
        
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
        marker.map = self.googleMap
        
        //baseDictionary = marker.userData as! NSDictionary
        
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
        
        baseDictionary = marker.userData as! NSDictionary
        
        let locationDictionary = baseDictionary.value(forKey: "origin") as! NSDictionary
        
        let location = CLLocationCoordinate2D(latitude: locationDictionary.value(forKey: "lat") as! CLLocationDegrees, longitude: locationDictionary.value(forKey: "long") as! CLLocationDegrees)
        
        let fullname = baseDictionary.value(forKey: "name") as? String ?? "no_name"
        let nameArray = fullname.components(separatedBy: " ")
        
        let name = nameArray[0] // changes to name to make it only show first name.
        let destination = baseDictionary.value(forKey: "destinationName") as! String //replaced destination with destinationName
        let rate = "\(baseDictionary.value(forKey: "rate")!)" //added ! here
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        
        // Reuse same infoWindow so we can disable "offer" button.
        infoWindow.destLabel.text = destination
        infoWindow.rateLabel.text = rate
        infoWindow.windowType = "Offer"
        infoWindow.nameLabel.text = name
        
        //infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100), type: "Driver", name: name, dest: destination, rate: rate)
        
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
        
        if(localDelegate.offeredID != "none") { // CHECK ON OFFER DOUBLE TAP CRASH!! COULD BE OFFERED ID BEING EMPTY ETC.
            // make a history item here. destination name+time.
            
            print("id \(localDelegate.offeredID)")
            
            let ref = FIRDatabase.database().reference()
            
            //history saving done here. grabbing what is not there causing crashes.
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/rider/\(self.localDelegate.offeredID)/").observeSingleEvent(of: .value, with: { snapshot in
                
                let dictionary = cellItem.init(snapshot: snapshot).toAnyObject() as! NSDictionary
                let ourID = FIRAuth.auth()!.currentUser!.uid
                self.ref.child("users/\(ourID)/history/\(dictionary.value(forKey: "destinationName")!)\(dictionary.value(forKey: "date"))/").setValue(dictionary)
                
                // add rider/driver name to thi
            })

        }
        
        let originLocal: NSDictionary = baseDictionary.value(forKey: "origin") as! NSDictionary
        let ourAddress : NSString = originLocal.value(forKey: "address") as! NSString
        localDelegate.riderAddress = ourAddress as String
        
        localDelegate.changeDriverStatus(status: "offer")
        localDelegate.offeredID = baseDictionary.value(forKey: "uid")! as! String
        
        print("Offer Tapped.")
        
        let checkRef = FIRDatabase.database().reference().child("requests/immediate/\(baseDictionary.value(forKey: "uid")!)/")
        let ref = FIRDatabase.database().reference().child("users/\(baseDictionary.value(forKey: "uid")!)/rider/offers/immediate/")
        
        let user = FIRAuth.auth()!.currentUser!
        
        let newOrigin = [ "lat": self.localDelegate.ourlat,
                          "long": self.localDelegate.ourlong,
                          "address": ourAddress ] as [String : Any]
        
        checkRef.observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.value! is NSNull) {
                print("null offer, no saves")
                
                let alert = UIAlertController(title: "Apologies", message: "But this rider is no longer looking for offers.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                    (action) in print("No offer")}))

                self.present(alert, animated: true, completion: {
                    print("preseting alert")
                })
                
            } else { 
                ref.child("\(user.uid)").setValue(
                    ["name": user.displayName!,
                     "uid": user.uid,
                     "venmoID": self.localDelegate.getVenmoID(),
                     //"origin": self.baseDictionary.value(forKey: "origin"),
                     "origin": newOrigin,
                     "destination": self.baseDictionary.value(forKey: "destination"),
                     "rate": self.baseDictionary.value(forKey: "rate"),
                     "accepted" : 0,
                     "repeats": self.baseDictionary.value(forKey: "repeats"),
                     "date": self.baseDictionary.value(forKey: "date"),
                     "destinationName": self.baseDictionary.value(forKey: "destinationName")
                    ]) //value set needs to be all of our info for the snapshot.
            
                print("ride offered") //this one is if you hit the snooze button
            
            //self.googleMap.clear() //clears the map of all pins so w can show only what we care about.
            
            //make the pin with only the riders info.
            //make tracker observers etc from only the baseDictionaries uid etc?...
            }
        })
        
        //maybe venmo id is a global var in app delegate with a getter/setter for moments like this.
        
        
        //self.googleMap.clear() //clears the map of all pins so w can show only what we care about.
        
        //make the pin with only the riders info.
        //make tracker observers etc from only the baseDictionaries uid etc?...
        
        //self.performSegue(withIdentifier: "driverAcceptsSegue", sender: self)
        print("end of ride accept")
        localDelegate.driverStatus = "offer"
        localDelegate.startDriverMapObservers()
        infoWindow.acceptButton.alpha = 0
        infoWindow.removeFromSuperview()
    }
    
    func declineTapped(button: UIButton) -> Void {
        print("Decline Tapped")
        infoWindow.removeFromSuperview()
        
        //driver could have same functionality, change his accepted value and remove it to warn the user that the driver had to cancel.
        if(localDelegate.driverStatus == "accepted"){
            //set our accepted value to 0 and then delete our branch before removing the whole offer.
            let uid = FIRAuth.auth()!.currentUser!.uid
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/\(uid)/accepted/").setValue(0);
            sleep(1);
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/driver/").removeValue()
            ref.child("users/\(self.localDelegate.offeredID)/rider/offers/accepted/immediate/").removeValue()
            localDelegate.driverStatus = "request"
            localDelegate.offeredID = "none"
            localDelegate.timer.invalidate()
            googleMap.clear()
        }
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
            marker.userData = cellInfo
            baseDictionary = marker.userData as! NSDictionary
            marker.title = "Rider: \(cellInfo["name"])"
            marker.map = self.googleMap
            
            print("in acceptance, we are watching: \(cellInfo["uid"]!)")
            //the origin in this line might need to be origin/ to allow for realtime pin tracking, play with this without me if you
            //guys need to work it.
            self.ref.child("users/\(cellInfo["uid"]!)/rider/offers/accepted/immediate/rider/\(cellInfo["uid"]!)/origin/").observe( .childChanged, with: { snapshot in
                print("watching marker moving!! \(snapshot.key)")
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
            
            ref.child("users/\(cellInfo["uid"]!)/rider/offers/accepted/immediate/rider/").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                print("PIN BEING DELETED")
                marker.map = nil;
                self.ref.child("users/\(cellInfo["uid"]!)/rider/offers/accepted/immediate/rider/\(cellInfo["uid"]!)/origin/").removeAllObservers()
                
                let content = UNMutableNotificationContent()
                content.title = "Ride Event"

                let baseDictionary = cellItem.init(snapshot: snapshot).toAnyObject() as! NSDictionary //need cell item before dictionary.

                if(baseDictionary.value(forKey: "accepted") as! NSInteger != 1) {
                    content.body = "The ride request has been removed. You do not need to pick up this individual."
                } else {
                    content.body = "Thank you for giving this user a ride."
                }
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "nothing_category"

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                let identifier = "ride acceptance"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                
                self.localDelegate.center.add(request, withCompletionHandler: { (error) in
                    print("adding driver notification")
                    if let error = error {
                        
                        print(error.localizedDescription)
                    }
                })
                
                self.localDelegate.offeredID = "none"
                self.localDelegate.driverStatus = "request"
                self.localDelegate.timer.invalidate()
                self.infoWindow.acceptButton.alpha = 1
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
