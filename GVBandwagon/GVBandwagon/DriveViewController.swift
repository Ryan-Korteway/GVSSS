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
    @IBOutlet var goOnlineButton: UIButton!
    
    var isMessageDisplayed = false
    let locationManager = CLLocationManager()
    
    let ref = FIRDatabase.database().reference();
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //user location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .automotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.createMap()

        //TEST MARKER CANCELLED OUT DUE TO BEING FILLED WITH LOCATION INSTEAD OF cellItem user data and being hard to change.
        
//        // Test Marker
//        let testMarker = GMSMarker()
//        testMarker.position = CLLocationCoordinate2D(latitude: 42.973984, longitude: -85.695527)
//        //marker.title = "Potential Rider: \(cellInfo["name"])"
//        //marker.snippet = "Close enough to Grand Valley."
//        testMarker.icon = GMSMarker.markerImage(with: .green)
//        testMarker.map = self.googleMap
//        
////        let name = "Nick"
////        let dest = "Downtown"
////        let rate = "$5"
////        let lat = testMarker.position.latitude
////        let lon = testMarker.position.longitude
////        let user: location = location(lat: lat, lon: lon, name: name, dest: dest, rate: rate)
//        
//        let newCell :cellItem
//        newCell.uid = "bing"
//        newCell.name = "ryan"
//        newCell.accepted = 0;
//        newCell.duration = 0;
//        newCell.rate = 12;
//        newCell.repeats = 0;
//        newCell.venmoID = "blazePyro"
//        
//        testMarker.userData = newCell
//        
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
        let destinationInfo: NSDictionary = cellInfo["destination"] as! NSDictionary
        
        print("our start lat and long are \(locationInfo["lat"]) and \(locationInfo["long"])")
        
        print("our start lat and long are \(locationInfo.value(forKey: "lat") as! CLLocationDegrees) \(locationInfo.value(forKey: "long") as! CLLocationDegrees)")
        
        let marker = GMSMarker()
        
        let lat = locationInfo.value(forKey: "lat") as! CLLocationDegrees
        let long = locationInfo.value(forKey: "long") as! CLLocationDegrees
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "Potential Rider: \(cellInfo["name"])"
        marker.snippet = "Close enough to Grand Valley."
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.userData = cellInfo //giving each marker a dictionary of the info that set them up for future use.
        marker.map = self.googleMap
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: destinationInfo.value(forKey: "latitude") as! CLLocationDegrees, longitude: destinationInfo.value(forKey: "longitude") as! CLLocationDegrees)
        marker2.userData = cellInfo
        marker2.title = "Potential Rider Destination"
        marker2.snippet = "Close enough to Grand Valley."
        
        marker2.map = self.googleMap
        
        // same here needing observers to update the pins with the riders locations as they move
        
        let standard = GMSMarker()
        standard.position = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        standard.title = "test"
        standard.snippet = "far"
        standard.icon = GMSMarker.markerImage(with: .red)
        standard.map = self.googleMap

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
    
    // initialize and keep a marker and a custom infowindow
    var tappedMarker = GMSMarker()
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let baseDictionary = marker.userData as! NSDictionary
        let locationDictionary = baseDictionary.value(forKey: "origin") as! NSDictionary
        
        let location = CLLocationCoordinate2D(latitude: locationDictionary.value(forKey: "lat") as! CLLocationDegrees, longitude: locationDictionary.value(forKey: "long") as! CLLocationDegrees)
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        infoWindow.nameLabel.text = baseDictionary.value(forKey: "name") as! NSString
        infoWindow.destLabel.text = baseDictionary.value(forKey: "destination") as! NSDictionary
        infoWindow.rateLabel.text = baseDictionary.value(forKey: "rate")
        
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
            let location = CLLocationCoordinate2D(latitude: (tappedMarker.userData as! location).lat, longitude: (tappedMarker.userData as! location).lon)
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y -= 90
        }
    }
    
    // take care of the close event
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    func acceptTapped(button: UIButton) -> Void {
        print("Accept Tapped")
    }
    
    func declineTapped(button: UIButton) -> Void {
        print("Decline Tapped")
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
