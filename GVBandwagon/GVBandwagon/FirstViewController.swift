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

class FirstViewController: UIViewController, rider_notifications {

    @IBOutlet var rideNowButton: UIButton!
    @IBOutlet var scheduleRideButton: UIButton!
    @IBOutlet var superViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var googleMapsView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    
    //TODO TAKE OUT THE HARD CODED LAT AND LONGS.
    var startingFrom: NSDictionary = ["lat": 43.013570, "long": -85.775875 ]
    var goingTo: NSDictionary = ["lat": 42.013570, "long": -85.775875]
    
    //let userid = "0001" //hardcoded values, should be the fireauth current user stuff.
    let currentUser = FIRAuth.auth()!.currentUser
    let pickerData: [String] = ["Allendale", "Meijer", "Downtown"]
    
    let ref = FIRDatabase.database().reference()
    var uid_forDriver = "wait";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.rideNowButton.layer.borderWidth = 1
        self.rideNowButton.layer.borderColor = UIColor.blue.cgColor
        
        self.scheduleRideButton.layer.borderWidth = 1
        self.scheduleRideButton.layer.borderColor = UIColor.blue.cgColor
        
        /* Link to pay on venmo
        UIApplication.shared.open(NSURL(string:"https://venmo.com/?txn=pay&audience=private&recipients=@michael-christensen-20&amount=3&note=GVB") as! URL, options: [:], completionHandler: nil)
         */
        
        //user location stuff
        //locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //locationManager.activityType = .automotiveNavigation
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
        
        self.createMap()

        
        
    } //end of view did load.
    
    // 6
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserInfo(name: String, phone: String) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        self.ref.child("users/\(userID)/name").setValue(name)
        self.ref.child("users/\(userID)/phone").setValue(phone)
    }
    
    
    // Ride Now button. Inside code, will add UI elements later.
    // Looking into adding an on-screen "bar" for searching up addresses, etc.
    // Will take some time.
    @IBAction func onRideNowTapped(_ sender: Any) {
        
        //need text alerts asking for a valid address that they want to head to, and their origin will just be their current lat and long if allowed, else we need to ask them for their starting address as well.
        
        //TODO, set up the text alerts to ask for a destination address, and if we are not allowed to just get the users location from their phone, then we need to ask them for requests as well.
        
        //if the look up results can fail, we may need while loops to ask for the address over and over again if the user fails to enter a valid address the second time.
        
        let alert = UIAlertController(title:"Ride Alert", message:"Your ride request will be presented to any available drivers nearby. If you do not hear back quickly enough, try remaking your request with a higher rate offer.", preferredStyle: .alert);
            
            let defaultAction = UIAlertAction(title:"OK", style:.default) { action -> Void in
            }
            
            alert.addAction(defaultAction);
            self.present(alert, animated:true, completion:nil);
       
            print("Leaving from \(self.startingFrom)")
            print("Going to \(self.goingTo)")
            
            ref.child("requests/immediate/\(currentUser!.uid)/").setValue(["name": currentUser!.displayName!, "uid": currentUser!.uid, "venmoID": "none", "ref": ref, "origin": self.startingFrom, "destination": self.goingTo, "rate" : 15, "accepted": 0]) //locations being sent here.
        
        //This works out nicely because making a new request would override the old one in case it goes on too long.
        
            return;
    }
    
    // Plan on doing the same for Schedule Ride button as Ride Now.
    // Would rather have a view pop up over the map in which the user
    // can enter info rather than switch to a entirely new view controller.
    @IBAction func onScheduleRideTapped(_ sender: Any) {
    }

    @IBAction func toggleLeftDrawer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender: sender as AnyObject, animated: false)
    }
    
    func createMap() {
        
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
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
        
        //TO DO make an observer that updates this particular pins position each time that the pins
        //lats and longs are updated. And on the drivers side we need to set up the correct timers
        //to update said pins lats and longs every 30 seconds to 1 minute as the driver is moving etc.
        
        let cellInfo: NSDictionary = item.toAnyObject() as! NSDictionary
        let locationInfo: NSDictionary = cellInfo["origin"] as! NSDictionary
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locationInfo.value(forKey: "lat") as! CLLocationDegrees, longitude: locationInfo.value(forKey: "long") as! CLLocationDegrees)
        marker.title = "Driver: \(cellInfo["name"])"
        marker.snippet = "Close enough to Grand Valley."
        marker.map = self.googleMapsView
        
        //so it would be down here that we would set up an observer based on potentially the reference
        //from the cell item itself, or at the least we can create the path by hand from the cell items
        //uid and just knowing the rest of the path. then whenever the observer gets triggered, the markers posistions just get reset to the new lats and longs.
        
        self.ref.child("/users/\(currentUser!.uid)/rider/offers/immediate/\(cellInfo["uid"]))").observe( .value, with: { snapshot in
             let newCell = cellItem.init(snapshot: snapshot)
             let newInfo = newCell.toAnyObject() as! NSDictionary
             let newLocation = newInfo["origin"] as! NSDictionary
            
            marker.position = CLLocationCoordinate2D(latitude: newLocation.value(forKey: "lat") as! CLLocationDegrees, longitude: newLocation.value(forKey: "long") as! CLLocationDegrees)
        }) //hopefully this makes the pins update their locations and then its needed in the driver stuff to set up the driver to update these fields.
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
        var locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if let location = locations.last {
            
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            //self.googleMapsView.animate(to: camera)
            self.googleMapsView.camera = camera
            
            locationManager.stopUpdatingLocation()
        } else {
            print("No location found!")
        }
    }
}
