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

class RequestRideViewController: UIViewController, UISearchBarDelegate {
    
    var placesClient: GMSPlacesClient!
    
    // Passed from previous (Ride) view controller:
    var visibleRegion: GMSVisibleRegion!
    var coordLocation: CLLocationCoordinate2D!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
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
    var destName: NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        placesClient = GMSPlacesClient.shared()
        
        // Google Places
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchBar.delegate = self
        searchController?.searchResultsUpdater = resultsViewController
        
        //let subView = UIView(frame: CGRect(x: 0, y: 250, width: 350.0, height: 45.0)) // Remove?
        
        searchView.addSubview((searchController?.searchBar)!)
        //subView.addSubview((searchController?.searchBar)!) // Remove?
        //view.addSubview(subView) // Remove?
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Google Places End
        
        self.configSwitches()
        
        //self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y, width: self.freqView.frame.width, height: 0)
        
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
        var newAlpha: CGFloat = 0
        
        if (isOn) {
            newHeight = 300
            newY = 300
            newAlpha = 1
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.freqView.frame = CGRect(x: self.freqView.frame.origin.x, y: self.freqView.frame.origin.y, width: self.freqView.frame.width, height: newHeight)
            
            self.offerLabel.frame = CGRect(x: self.offerLabel.frame.origin.x, y: self.offerLabel.frame.origin.y + newY, width: self.offerLabel.frame.width, height: self.offerLabel.frame.height)
            self.dollarSignLabel.frame = CGRect(x: self.dollarSignLabel.frame.origin.x, y: self.dollarSignLabel.frame.origin.y + newY, width: self.dollarSignLabel.frame.width, height: self.dollarSignLabel.frame.height)
            self.offerTextField.frame = CGRect(x: self.offerTextField.frame.origin.x, y: self.offerTextField.frame.origin.y + newY, width: self.offerTextField.frame.width, height: self.offerTextField.frame.height)
            
            self.freqView.alpha = newAlpha
            
        }, completion: { (Bool) -> Void in
            // Do nothing.
        })
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        self.getSwitchInfo()
        
        //all this to be moved into new view controller logic at some point.
        
        //SELF GOING TO NEED REPLACING WITH THE SEARCHING OF A DESTINATION FROM THE PAGE.
        
        let currentLat = self.localDelegate.locationManager.location!.coordinate.latitude
        let currentLong = self.localDelegate.locationManager.location!.coordinate.longitude
        
        print("Current lat and long: \(currentLat) \(currentLong)")
        
        ref.child("requests/immediate/\(currentUser!.uid)/").setValue(["name": currentUser!.displayName!, "uid": currentUser!.uid, "venmoID": "none", "origin": ["lat": currentLat, "long": currentLong], "destination": ["latitude": destLat, "longitude" : destLong], "destinationName": destName, "rate" : NSInteger.init(self.offerTextField.text!)!, "accepted": 0, "repeats": freqArray.description, "duration": "none"]) //locations being sent here.
        
        //repeats, duration, and destination needs to be set dynamically!!!
        
        localDelegate.startTimer();
        //localDelegate.status = "offer"
        _ = self.navigationController?.popViewController(animated: true)
        
        for day in freqArray {
            print(day)
        }
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
        //let visibleRegion = rideVC.googleMapsView.projection.visibleRegion()
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
    
    func sendRequestToFirebase(destination: GMSPlace) {
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
        sendRequestToFirebase(destination: place)
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
