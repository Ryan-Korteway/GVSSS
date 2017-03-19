//
//  FirstViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/20/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class FirstViewController: UIViewController, GMSMapViewDelegate, rider_notifications {
    
    var localDelegate: AppDelegate!

    @IBOutlet var rideNowButton: UIButton!
    @IBOutlet var superViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var googleMapsView: GMSMapView!
    
    // initialize and keep a marker and a custom infowindow
    var tappedMarker = GMSMarker()
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    var baseDictionary: NSDictionary = [:]
    
    //var localCell = cellItem(start: ["name":"filler", "uid": "filler", "venmoID": "filler", "origin": ["lat": 0.0, "long": 0.0], "destination": ["longitude": 0.0, "latitude": 0.0], "rate": 0, "accepted": 0, "repeats": 0, "duration": "none"])
    
    let locationManager = CLLocationManager()

    let ref = FIRDatabase.database().reference()
    var uid_forDriver = "wait";
    
    var ourLat = 0.0
    var ourLong = 0.0
    
    // For the Ride Now button
    var shadowLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    
        // Custom button design. We should put this in its own clas later.
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: self.rideNowButton.bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.blue.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2
            
            self.rideNowButton.layer.insertSublayer(shadowLayer, at: 0)
        }
        
        /* Link to pay on venmo
        UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@michael-christensen-20&amount=3&note=GVB") as! URL, options: [:], completionHandler: nil)
         */
        
        self.createMap()
        
        localDelegate = UIApplication.shared.delegate as! AppDelegate
        print("delegate being set")
        localDelegate.firstViewController = self; //hopefully this cast is okay.
        localDelegate.firstSet = true;
        localDelegate.lastState = "rider"
        
        localDelegate.startRiderMapObservers() //the new function to populate the riders map each time the view loads.
        
    } //end of view did load.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        localDelegate.startRiderMapObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Ride Now button. Inside code, will add UI elements later.
    // Looking into adding an on-screen "bar" for searching up addresses, etc.
    // Will take some time.
    @IBAction func onRideNowTapped(_ sender: Any) {
            return;
    }

    @IBAction func toggleLeftDrawer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender: sender as AnyObject, animated: false)
    }
    
    @IBAction func onUserPanelTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender: sender as AnyObject, animated: false)
        if let panelVC = appDelegate.drawerViewController.rightViewController as? DriverPanelViewController {
            panelVC.mode = "Ride"
        }
    }
    
    func createMap() {
        
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.googleMapsView.delegate = self
        
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 51.507351, longitude: -0.127758)
//        marker.title = "Driver"
//        marker.snippet = "Close enough to Grand Valley."
//        marker.icon = GMSMarker.markerImage(with: .blue) //custom icon color code here.
        // can also do marker.icon = UIImage(named: "house") and then our app would just have to have a house.png file in it to use that marker. better to use a constant to hold that UIImage and to set the icon off of that instead of doing lots of redeclarations/assignments fresh each time.
        //marker.map = self.googleMapsView
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func isRider() -> Bool {
        return true;
    }
    
    func isDriver() -> Bool {
        return false;
    }
    
    func ride_offer(item: cellItem) {
        
        print("ride offer being made")
        
        let cellInfo: NSDictionary = item.toAnyObject() as! NSDictionary
        let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
        
        let marker = GMSMarker()
        let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
        let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
        
        print("Lat and Long: \(lat) : \(long)")

        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        //marker.title = "Driver: \(cellInfo["name"])"
        //marker.snippet = "Close enough to Grand Valley."
        marker.map = self.googleMapsView
        marker.userData = cellInfo
        
        print("our driver uid \(cellInfo["uid"]!)")
        
        let currentUser = FIRAuth.auth()!.currentUser
        self.ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)/origin").observe( .childChanged, with: { snapshot in
            
                print("\(snapshot.key)")
            if(snapshot.key == "lat") {
                marker.position.latitude = snapshot.value as! CLLocationDegrees
            } else {
                marker.position.longitude = snapshot.value as! CLLocationDegrees
            }
        }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
        //once we accept the offer, we will need a .value to get each key to remove each observer before we delete the whole section.
        
        ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
            print("PIN BEING DELETED")
            marker.map = nil;
            self.ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)/origin").removeAllObservers()
        })

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "riderAcceptsSegue" {
            if let nextVC = segue.destination as? RideSummaryTableViewController {
                // Set the attributes in the next VC.
                nextVC.paymentText = "Submit Payment"
                //here i could grab a global accepts dictionary and send it over to the other view controller..
            }
        }
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
        
        func ride_accept(item: NSDictionary) { //all map set ups/marker creations may need to be in their own functions in ride and drive
        //view controllers so that upon the map being reloaded, it can be repopulated with the correct data given the current user state.
        
        let user = FIRAuth.auth()!.currentUser!
        let cellInfo: NSDictionary = item
        let ref = FIRDatabase.database().reference().child("users/\(user.uid)/rider/")
        let topRef = FIRDatabase.database().reference()
        
        topRef.child("requests/immediate/\(user.uid)").removeValue()
        
        print("our driver uid \(cellInfo.value(forKey: "uid")!)")
        
        print("our cellInfo \(cellInfo.description)")
            
        ref.child("offers/immediate/\(cellInfo.value(forKey: "uid")!)/accepted").setValue(1); //set the accepted drivers accepted value to 1.
        
        ref.child("offers/immediate/\(cellInfo.value(forKey: "uid")!)").observeSingleEvent(of: .value, with: { snapshot in
            let dictionary: NSDictionary = snapshot.value! as! NSDictionary
            ref.child("offers/accepted/immediate/driver/\(cellInfo.value(forKey: "uid")!)").setValue(dictionary) //create an accepted branch of the riders table
            
            ref.child("offers/accepted/immediate/rider/\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": "none", "origin": ["lat": self.ourLat, "long": self.ourLong], "destination": dictionary.value(forKey: "destination"), "rate" : dictionary.value(forKey: "rate"), "accepted": 0, "repeats": 0, "duration": dictionary.value(forKey: "duration")])
            
            let localDelegate = UIApplication.shared.delegate as! AppDelegate
            localDelegate.status = "accepted"
                
            ref.child("offers/immediate/").removeValue() //remove the offers immediate branch from the riders account so that the drivers are able to observe the destruction and if they were selected or not.
            
            self.googleMapsView.clear()
            
            //call make pins function.
            localDelegate.startRiderMapObservers()
        })
        
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
        localDelegate.changeStatus(status: "accepted")
        print("Accept Tapped.")
        
        ride_accept(item: baseDictionary) //local cell assignment might be bad/fail here.
    }
    
    
    func declineTapped(button: UIButton) -> Void {
        print("Decline Tapped")
        infoWindow.removeFromSuperview()
    }
        
    func fillWithAcceptance(item: cellItem) {
        let cellInfo = item.toAnyObject() as! NSDictionary
        let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
        
        let marker = GMSMarker()
        let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
        let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
            
        let locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "Driver: \(cellInfo["name"])"
        marker.map = self.googleMapsView
        marker.userData = cellInfo
            //self.googleMapsView.animate(to: camera)
            let currentUser = FIRAuth.auth()!.currentUser
        
            print("in acceptance, we are watching: \(cellInfo["uid"]!)")
        
            self.ref.child("users/\(currentUser!.uid)/rider/accepted/immediate/driver/\(cellInfo["uid"]!)/origin").observe( .childChanged, with: { snapshot in
                if(snapshot.key == "lat") {
                    marker.position.latitude = snapshot.value as! CLLocationDegrees
                } else {
                    marker.position.longitude = snapshot.value as! CLLocationDegrees
                }
            }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
            
            self.ref.child("users/\(currentUser!.uid)/rider/accepted/immediate/driver/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                print("PIN BEING DELETED")
                marker.map = nil;
                self.ref.child("users/\(currentUser!.uid)/rider/accepted/immediate/driver/\(cellInfo["uid"]!)/origin").removeAllObservers()
            })
        
        }
}

extension FirstViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            self.googleMapsView.isMyLocationEnabled = true
            self.googleMapsView.settings.myLocationButton = true
        } else {
            print("\nNOT AUTHORIZED\n")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            if let location = locations.last {
                
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                let locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
                self.ourLat = locValue.latitude
                self.ourLong = locValue.longitude
            self.googleMapsView.camera = camera
            
            locationManager.stopUpdatingLocation()
        } else {
            print("No location found!")
        }
    }
}

/* Code graveyard, should this code be needed again somewhere else.
 
 
 let ref = FIRDatabase.database().reference().child("users/\(baseDictionary.value(forKey: "uid")!)/rider/offers/immediate/")
 
 let user = FIRAuth.auth()!.currentUser!
 
 //idk about user.displayName here.
 
 //maybe venmo id is a global var in app delegate with a getter/setter for moments like this.
 ref.child("\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": localDelegate.getVenmoID(), "origin": baseDictionary.value(forKey: "origin"), "destination": baseDictionary.value(forKey: "destination"), "rate": baseDictionary.value(forKey: "rate"), "accepted" : 0, "repeats": 0, "duration": "none"]) //value set needs to be all of our info for the snapshot.
 
 print("ride offered") //this one is if you hit the snooze button
 
 self.googleMapsView.clear() //clears the map of all pins so w can show only what w care about.
 
 //make the pin with only the riders info.
 //make tracker observers etc from only the baseDictionaries uid etc?...
 
 // If the RIDER accepts, we want to go to riderAcceptsSegue
 performSegue(withIdentifier: "riderAcceptsSegue", sender: self)
 infoWindow.removeFromSuperview()
 
 // Set Active Trip of Right Drawer to riders name and set it to clickable.
 
 
 */
