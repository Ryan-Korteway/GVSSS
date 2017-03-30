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
import GooglePlaces

//TODO: Each viewDidLoad, check didLoadMapsYet and set googleMapsView = persisted map.  
class FirstViewController: UIViewController, GMSMapViewDelegate, rider_notifications {
    
    var localDelegate: AppDelegate!
    
    var placesClient: GMSPlacesClient!

    @IBOutlet var rideNowButton: UIButton!
    @IBOutlet var superViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var googleMapsView: GMSMapView!
    
    // initialize and keep a marker and a custom infowindow
    var tappedMarker = GMSMarker()
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100), type: "Rider", name: "Name", dest: "Destination", rate: "$5")
    
    var baseDictionary: NSDictionary = [:]
    
    let locationManager = CLLocationManager()

    let ref = FIRDatabase.database().reference()
    var uid_forDriver = "wait"; //might need to save and repull this later...
    
    var ourLat = 0.0
    var ourLong = 0.0
    
    // For the Ride Now button
    var shadowLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        // Custom button design. We should put this in its own class later.
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
        
        //NEED TO PULL DOWN/RESET RIDER STATUS here.
        
        self.ref.child("users/\(FIRAuth.auth()!.currentUser!.uid)/stateVars/riderStatus").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value! is String else {
                    self.localDelegate.riderStatus = "request"
                    self.localDelegate.startRiderMapObservers()//the new function to populate the riders map each time the view loads.
                    return
            }
                self.localDelegate.riderStatus = snapshot.value! as! String
                self.localDelegate.startRiderMapObservers() //the new function to populate the riders map each time the view loads.
                return
        })
        
    } //end of view did load.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        localDelegate.startRiderMapObservers()
        
        self.ref.child("users/\(FIRAuth.auth()!.currentUser!.uid)/stateVars/riderStatus").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value! is String else {
                self.localDelegate.riderStatus = "request"
                self.localDelegate.startRiderMapObservers()//the new function to populate the riders map each time the view loads.
                return
            }
            self.localDelegate.riderStatus = snapshot.value! as! String
            self.localDelegate.startRiderMapObservers() //the new function to populate the riders map each time the view loads.
            return
        })
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
            panelVC.goOnlineSwitch.isHidden = true
            panelVC.goOnlineLabel.isHidden = true
            panelVC.viewReload()
            panelVC.getRating()
        }
    }
    
    func createMap() {

        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.googleMapsView.settings.compassButton = true
        self.googleMapsView.delegate = self
        
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
        self.ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)/origin/").observe( .childChanged, with: { snapshot in
            
                print("\(snapshot.key)")
            if(snapshot.key == "lat") {
                marker.position.latitude = snapshot.value as! CLLocationDegrees
            } else if (snapshot.key == "long") {
                marker.position.longitude = snapshot.value as! CLLocationDegrees
            } else {
                self.localDelegate.ourAddress = snapshot.value as! NSString
            }
        }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
        //once we accept the offer, we will need a .value to get each key to remove each observer before we delete the whole section.
        
        ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
            print("PIN BEING DELETED")
            marker.map = nil;
            self.ref.child("users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]!)/origin/").removeAllObservers()
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "riderAcceptsSegue" {
            if let nextVC = segue.destination as? RideSummaryTableViewController {
                // Set the attributes in the next VC.
                nextVC.informationDictionary = baseDictionary
                
                nextVC.paymentText = "Submit Payment"
                //here i could grab a global accepts dictionary and send it over to the other view controller..
                
                // Get riders current place
                // address = an NSString of the address where the user is.
                self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                    if let error = error {
                        print("Pick Place error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let place = placeLikelihoodList?.likelihoods.first?.place {
                        if let address = place.formattedAddress {
                            nextVC.localAddress = address
                        }
                    }
                })
                // End get riders current place
                
            }
        } else if segue.identifier == "toRequestRideSegue" {
            if let nextVC = segue.destination as? RequestRideViewController {
                nextVC.visibleRegion = self.googleMapsView.projection.visibleRegion()
                nextVC.coordLocation = self.locationManager.location?.coordinate
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
        self.baseDictionary = marker.userData as! NSDictionary
        let locationDictionary = baseDictionary.value(forKey: "origin") as! NSDictionary
        
        let location = CLLocationCoordinate2D(latitude: locationDictionary.value(forKey: "lat") as! CLLocationDegrees, longitude: locationDictionary.value(forKey: "long") as! CLLocationDegrees)
        
        let name = (baseDictionary.value(forKey: "name") as! NSString) as String
        let destination = baseDictionary.value(forKey: "destinationName") as! String
        let rate = "\(baseDictionary.value(forKey: "rate")!)"
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100), type: "Rider", name: name, dest: destination, rate: rate)
            
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
            
            ref.child("offers/accepted/immediate/rider/\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": "none", "origin": ["lat": self.ourLat, "long": self.ourLong, "address": self.localDelegate.ourAddress], "destination": dictionary.value(forKey: "destination"), "rate" : dictionary.value(forKey: "rate"), "accepted": 1, "repeats": "none", "duration": dictionary.value(forKey: "duration"), "destinationName": dictionary.value(forKey: "destinationName")])
            
            let localDelegate = UIApplication.shared.delegate as! AppDelegate
            localDelegate.riderStatus = "accepted"
            
            print("we have accepted")
            
            ref.child("offers/immediate/").removeValue() //remove the offers immediate branch from the riders account so that the drivers are able to observe the destruction and if they were selected or not.
            
            self.googleMapsView.clear()
            
            //call make pins function.
            localDelegate.startRiderMapObservers()
            
        })
        
        print("\nride_accept was called!\n")
        
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
        localDelegate.changeRiderStatus(status: "accepted")
        print("Accept Tapped.")
        
        ride_accept(item: baseDictionary) //local cell assignment might be bad/fail here.
        infoWindow.removeFromSuperview()
        
        // TODO: Disable infoWindow now, or just show the info, not the buttons.
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
        
        baseDictionary = marker.userData as! NSDictionary
            //self.googleMapsView.animate(to: camera)
            let currentUser = FIRAuth.auth()!.currentUser
        
            print("in acceptance, we are watching: \(cellInfo["uid"]!)")
        
            self.ref.child("users/\(currentUser!.uid)/rider/offers/accepted/immediate/driver/\(cellInfo["uid"]!)/origin/").observe( .childChanged, with: { snapshot in
                if(snapshot.key == "lat") {
                    marker.position.latitude = snapshot.value as! CLLocationDegrees
                } else if (snapshot.key == "long"){
                    marker.position.longitude = snapshot.value as! CLLocationDegrees
                } else {
                    self.localDelegate.ourAddress = snapshot.value as! NSString
                }
            }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
            
            self.ref.child("users/\(currentUser!.uid)/rider/offers/accepted/immediate/driver/\(cellInfo["uid"]!)").observeSingleEvent(of: .childRemoved, with:{ snapshot in
                print("PIN BEING DELETED")
                marker.map = nil;
                self.ref.child("users/\(currentUser!.uid)/rider/offers/accepted/immediate/driver/\(cellInfo["uid"]!)/origin/").removeAllObservers()
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
