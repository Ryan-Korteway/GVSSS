//
//  RequestRideViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/15/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import UserNotifications

class RequestRideViewController: UIViewController, UISearchBarDelegate {
    
    var placesClient: GMSPlacesClient!
    
    // Passed from previous (Ride) view controller:
    var visibleRegion: GMSVisibleRegion!
    var coordLocation: CLLocationCoordinate2D!
    
    @IBOutlet var scrollView: UIScrollView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let center = UNUserNotificationCenter.current()

    
    @IBOutlet var searchView: UIView!
    @IBOutlet var monSwitch: UISwitch!
    @IBOutlet var tuesSwitch: UISwitch!
    @IBOutlet var wedSwitch: UISwitch!
    @IBOutlet var thurSwitch: UISwitch!
    @IBOutlet var friSwitch: UISwitch!
    @IBOutlet var satSwitch: UISwitch!
    @IBOutlet var sunSwitch: UISwitch!

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var submitButton: UIBarButtonItem!
    
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var freqSwitchView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateView: UIView!
    @IBOutlet var freqSwitch: UISwitch!
    @IBOutlet var freqView: UIView!
    @IBOutlet var offerLabel: UILabel!
    @IBOutlet var dollarSignLabel: UILabel!
    @IBOutlet var offerTextField: UITextField!
    let ref = FIRDatabase.database().reference()
    let currentUser = FIRAuth.auth()!.currentUser
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var freqArray = [String]()
    
    var startingFrom: NSDictionary = ["lat": 43.013570, "long": -85.775875 ]
    var goingTo: NSDictionary = ["latitude": 42.013570, "longitude": -85.775875]
    
    var destLat : Double = 0.0
    var destLong : Double = 0.0
    var destName: NSString? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        self.offerTextField.text = "2"
        self.offerTextField.keyboardType = UIKeyboardType.decimalPad
        
        placesClient = GMSPlacesClient.shared()
        
        // Google Places
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchBar.delegate = self
        searchController?.searchResultsUpdater = resultsViewController
        

        
        searchView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Google Places End
        
        self.configSwitches()
        
        self.freqSwitch.setOn(false, animated: false)
        self.freqSwitch.addTarget(self, action: #selector(switchIsChanged(mySwitch:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        
        if mySwitch.isOn {
            self.animateElements(isOn: true)
        } else {
            self.animateElements(isOn: false)
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateElements(isOn: Bool) -> Void {
        
        var newHeight: CGFloat = 0
        var newY: CGFloat = -300
        var switchViewY: CGFloat = 70
        var dateViewHeight: CGFloat = 35
        var newAlpha: CGFloat = 0
        var dateAlpha: CGFloat = 1
        
        
        if (isOn) {
            newHeight = 300
            newY = 300
            dateViewHeight = 0
            switchViewY = -70
            newAlpha = 1
            dateAlpha = 0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            //self.dateView.frame = CGRect(x: self.dateView.frame.origin.x, y: self.dateView.frame.origin.y, width: self.dateView.frame.width, height: dateViewHeight)
            self.dateView.alpha = dateAlpha
            
            
            self.freqSwitchView.frame = CGRect(x: self.freqSwitchView.frame.origin.x, y: self.freqSwitchView.frame.origin.y + switchViewY, width: self.freqSwitchView.frame.width, height: self.freqSwitchView.frame.height)
            
            self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y, width: self.freqView.frame.width, height: newHeight)
            
            self.offerLabel.frame = CGRect(x: self.offerLabel.frame.origin.x, y: self.offerLabel.frame.origin.y + newY, width: self.offerLabel.frame.width, height: self.offerLabel.frame.height)
            self.dollarSignLabel.frame = CGRect(x: self.dollarSignLabel.frame.origin.x, y: self.dollarSignLabel.frame.origin.y + newY, width: self.dollarSignLabel.frame.width, height: self.dollarSignLabel.frame.height)
            self.offerTextField.frame = CGRect(x: self.offerTextField.frame.origin.x, y: self.offerTextField.frame.origin.y + newY, width: self.offerTextField.frame.width, height: self.offerTextField.frame.height)
            
            self.freqView.alpha = newAlpha
            
            // Increase scroll view size so we can scroll
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height + newY)
            
        }, completion: { (Bool) -> Void in
            // Do nothing.
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event);
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        self.getSwitchInfo()
        
        print("destName: \(self.destName?.length)")
        if self.destName?.length == 0 || self.destName == nil {
            print("empty destName")
            //make an alert saying no offer there?
            
            let alert = UIAlertController(title: "Apologies", message: "Empty destination name, you must enter a valid destination name.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                (action) in print("dismissed")}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        // make a history item here. destination name+time.
        ref.child("users/\(userID)/rider/offers/accepted/immediate/driver/").observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.value! is NSNull) {
                print("null history, no saves")
            } else {
                let dictionary = cellItem.init(snapshot: snapshot).toAnyObject() as! NSDictionary
                let date = Date()
                self.ref.child("users/\(userID)/history/\(dictionary.value(forKey: "destinationName")!)\(date.description)/").setValue(dictionary)
            }
        })

        
        sendRequestToFirebase()
        
        localDelegate.riderStatus = "request"
        localDelegate.startTimer();
        _ = self.navigationController?.popViewController(animated: true)
        
        for day in freqArray {
            print(day)
        }
    }
    
    func sendRequestToFirebase() -> Void {
    
        let currentLat = self.localDelegate.locationManager.location!.coordinate.latitude
        let currentLong = self.localDelegate.locationManager.location!.coordinate.longitude
    
        print("Current lat and long: \(currentLat) \(currentLong)")
        
        // Get riders current place, in completion send to Firebase
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // address = an NSString of the address where the user is.
            if let place = placeLikelihoodList?.likelihoods.first?.place {
                if let address = place.formattedAddress {
                    print("address: \(address)")
                    let addr = address as NSString
            
                    var repeatsValue = "none"
                    
                    if self.freqArray.count > 0 {
                        repeatsValue = self.freqArray.description
                    }
//                    
//                    if(self.offerTextField.text?.canBeConverted(to: NSInteger)) {
//                        let rateValue = NSInteger.init(self.offerTextField.text?.
//                    } else {
//                        let rateValue =
//                    }

                    let rateValue = NSNumber.init(value: Float(self.offerTextField.text!)!)
                    
                    self.ref.child("requests/immediate/\(self.currentUser!.uid)/").setValue(["name": self.currentUser!.displayName!, "uid": self.currentUser!.uid, "venmoID": "none", "origin": ["lat": currentLat, "long": currentLong, "address": addr], "destination": ["latitude": self.destLat, "longitude" : self.destLong], "destinationName": self.destName!, "rate" : rateValue, "accepted": 0, "repeats": repeatsValue, "duration": "none"])
                                                                                                        //TODO DYNAMIC DURATION!!!
                }
            }
        })
        // End get riders current place
    }
    
    func getCurrentLocation() -> NSString {
        var addr: NSString = "Unknown"
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // address = an NSString of the address where the user is.
            if let place = placeLikelihoodList?.likelihoods.first?.place {
                if let address = place.formattedAddress {
                    print("address: \(address)")
                    addr = address as NSString
                }
            }
        })
        // End get riders current place
        
        return addr
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configSwitches() {
        self.monSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.tuesSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.wedSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.thurSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.friSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.satSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.sunSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.monSwitch.setOn(false, animated: false)
        self.tuesSwitch.setOn(false, animated: false)
        self.wedSwitch.setOn(false, animated: false)
        self.thurSwitch.setOn(false, animated: false)
        self.friSwitch.setOn(false, animated: false)
        self.satSwitch.setOn(false, animated: false)
        self.sunSwitch.setOn(false, animated: false)
    }
    
    func getSwitchInfo() {
        if monSwitch.isOn {
            freqArray.append("Monday")
        }
        if tuesSwitch.isOn {
            freqArray.append("Tuesday")
        }
        if wedSwitch.isOn {
            freqArray.append("Wednesday")
        }
        if thurSwitch.isOn {
            freqArray.append("Thursday")
        }
        if friSwitch.isOn {
            freqArray.append("Friday")
        }
        if satSwitch.isOn {
            freqArray.append("Saturday")
        }
        if sunSwitch.isOn {
            freqArray.append("Sunday")
        }
    }
    
    @IBAction func onDateViewTapped(_ sender: Any) {
        // Create picker constraints and apply to date picker after the window opens
        
        // Open and close variable
        var newHeight: CGFloat = 150
        var newY: CGFloat = 150
        var newAlpha: CGFloat = 1
        
        if (self.dateView.frame.height > 100) {
            newHeight = 35
            newY = -150
            newAlpha = 0
        }
        print(newHeight)
        print(newY)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.dateView.frame = CGRect(x: self.dateView.frame.origin.x, y: self.dateView.frame.origin.y, width: self.dateView.frame.width, height: newHeight)
            
            self.datePicker.alpha = newAlpha
            
            self.freqSwitchView.frame = CGRect(x: self.freqSwitchView.frame.origin.x, y: self.freqSwitchView.frame.origin.y + newY, width: self.freqSwitchView.frame.width, height: self.freqSwitchView.frame.height)
            
            self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y + newY, width: self.freqView.frame.width, height: self.freqView.frame.height)
            
            self.offerLabel.frame = CGRect(x: self.offerLabel.frame.origin.x, y: self.offerLabel.frame.origin.y + newY, width: self.offerLabel.frame.width, height: self.offerLabel.frame.height)
            self.dollarSignLabel.frame = CGRect(x: self.dollarSignLabel.frame.origin.x, y: self.dollarSignLabel.frame.origin.y + newY, width: self.dollarSignLabel.frame.width, height: self.dollarSignLabel.frame.height)
            self.offerTextField.frame = CGRect(x: self.offerTextField.frame.origin.x, y: self.offerTextField.frame.origin.y + newY, width: self.offerTextField.frame.width, height: self.offerTextField.frame.height)
            
            // Increase scroll view size so we can scroll
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height + newY)
            
        }, completion: { (Bool) -> Void in
            // Do nothing.
            
            /*
             UIView.animate(withDuration: 0.3, animations: {
             self.datePicker.frame = CGRect(x: self.datePicker.frame.origin.x, y: self.datePicker.frame.origin.y + newY, width: self.datePicker.frame.width, height: self.datePicker.frame.height)
             print("Frame y: \(self.datePicker.frame.origin.y)")
             }, completion: { (Bool) -> Void in
             // Do nothing
             })
             */
            
        })
    }
    
    
    @IBAction func placesPicker(_ sender: Any) {
        if let center = self.coordLocation {
            
            let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
            let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            let placePicker = GMSPlacePicker(config: config)

            placePicker.pickPlace(callback: {(place, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let place = place {
                    //self.namelabel.text = place.name
                    //self.addrlabel.text = place.formattedAddress?.components(separatedBy: ", ")
                    //.joined(separator: "\n")
                    self.setFirebaseRequest(destination: place)
                    self.searchController?.searchBar.placeholder = place.name
                    
                } else {
                    //self.namelabel.text = "No place selected"
                    //self.addrlabel.text = ""
                }
            })
        } else {
            print("self.coordLocation was not passed from the previous view controller!")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        let bounds = GMSCoordinateBounds(coordinate: self.visibleRegion.farLeft, coordinate: self.visibleRegion.nearRight)
        
        self.resultsViewController?.autocompleteBounds = bounds
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
            (results, error) -> Void in
            guard error == nil else {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                for result in results {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        })
    }
    
    /*
    func getAddressFromCoordinates(coord: CLLocationCoordinate2D) -> GMSPlace {
        let bounds = GMSCoordinateBounds(coordinate: coord, coordinate: coord)
        
        self.resultsViewController?.autocompleteBounds = bounds
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        var newPlace = GMSPlace()
        
        placesClient.autocompleteQuery("", bounds: bounds, filter: filter, callback: {
            (results, error) -> Void in
            guard error == nil else {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                if let result = results.first {
                    if let placeID = result.placeID {
                        print("Place ID from coordinates found: \(placeID)")
                        newPlace = self.getPlaceFromID(id: placeID)
                    }
                }
            }
        })
        
        return newPlace
    }
    
    func getPlaceFromID(id: String) -> GMSPlace {
        
        var newPlace = GMSPlace()
        
        self.placesClient.lookUpPlaceID(id, callback: {
            (results, error) -> Void in
            guard error == nil else {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                print("Place found: \(results.formattedAddress)")
                newPlace = results
            }
        })
        
        return newPlace
    }
    */
    
    func setFirebaseRequest(destination: GMSPlace) {
        print("Send to FB: Place name: \(destination.name)")
        print("Send: Place address: \(destination.formattedAddress)")
        print("Send: Place attributions: \(destination.attributions)")
        self.destLat = destination.coordinate.latitude
        self.destLong = destination.coordinate.longitude
        self.destName = destination.formattedAddress as NSString!
    }
}

extension RequestRideViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        setFirebaseRequest(destination: place)
        
        searchController?.searchBar.placeholder = place.name
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
