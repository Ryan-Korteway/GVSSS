//
//  RideRequestTableViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/31/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import UserNotifications

class RideRequestTableViewController: UITableViewController, UISearchBarDelegate {
    
    var placesClient: GMSPlacesClient!
    
    let DATE_CELL_SECTION = 1
    let FREQ_CELL_SECTION = 2
    
    // Passed from previous (Ride) view controller:
    var visibleRegion: GMSVisibleRegion!
    var coordLocation: CLLocationCoordinate2D!

    @IBOutlet weak var searchView: UIView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let center = UNUserNotificationCenter.current()

    let selectedDateHeight: CGFloat = 180
    let selectedFreqHeight: CGFloat = 150
    
    var isDateCellSelected = false
    var isFreqCellSelected = false
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var freqPicker: UIPickerView!
    @IBOutlet var freqPickerHeaderView: UIView!
    @IBOutlet weak var freqSwitch: UISwitch!
    
    // This is an optional because a cell is selected or isn't (this is nil)
    var selectedCellIndexPath: IndexPath?
    
    @IBOutlet var dateCell: UITableViewCell!
    @IBOutlet weak var dateTextField: UITextField!
    
    var freqArray = [String]()
    
    var pickerViewDelegate: UIPickerViewDelegate?
    
    let pickerComponents = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let pickerRows = ["No", "Yes"]
    
    let ref = FIRDatabase.database().reference()
    let currentUser = FIRAuth.auth()!.currentUser
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var destLat : Double = 0.0
    var destLong : Double = 0.0
    var destName: NSString? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.freqPicker.delegate = self
        self.freqPicker.dataSource = self
        self.freqPicker.alpha = 0
        self.freqPickerHeaderView.alpha = 0
        
        self.navigationController?.navigationBar.isHidden = false
        
        //self.offerTextField.text = "2"
        //self.offerTextField.keyboardType = UIKeyboardType.decimalPad
        
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

        
        self.freqSwitch.setOn(false, animated: false)
        self.freqSwitch.addTarget(self, action: #selector(switchIsChanged(mySwitch:)), for: .valueChanged)
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        
        if mySwitch.isOn {
            self.animateElements(isOn: true)
        } else {
            self.animateElements(isOn: false)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        self.view.endEditing(true)
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
                    
                    /*
                    let rateValue = NSNumber.init(value: Float(self.offerTextField.text!)!)
                    var repeatsValue = "none"
                    
                    if self.freqArray.count > 0 {
                        repeatsValue = self.freqArray.description
                    }
                    */
                    
                    self.ref.child("requests/immediate/\(self.currentUser!.uid)/").setValue(["name": self.currentUser!.displayName!, "uid": self.currentUser!.uid, "venmoID": "none", "origin": ["lat": currentLat, "long": currentLong, "address": addr], "destination": ["latitude": self.destLat, "longitude" : self.destLong], "destinationName": self.destName!, "rate" : (NSInteger.init(self.offerTextField.text!)) ?? 5, "accepted": 0, "repeats": self.freqArray.description, "duration": "none"]) //locations being sent here.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        if self.selectedCellIndexPath == indexPath {
            return self.selectedDateHeight
        }
        */
        if isDateCellSelected && indexPath.section == DATE_CELL_SECTION {
            return self.selectedDateHeight
        }
        
        if isFreqCellSelected && indexPath.section == FREQ_CELL_SECTION {
            return self.selectedFreqHeight
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == DATE_CELL_SECTION && !self.isDateCellSelected {
            self.isDateCellSelected = true
            self.datePicker.alpha = 1
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        } else {
            self.isDateCellSelected = false
            self.datePicker.alpha = 0
        }
        
        /*
        if indexPath.section == FREQ_CELL_SECTION && !self.isFreqCellSelected {
            self.isFreqCellSelected = true
            self.freqPicker.alpha = 1
            self.freqPickerHeaderView.alpha = 1
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        } else {
            self.isFreqCellSelected = false
            self.freqPicker.alpha = 0
            self.freqPickerHeaderView.alpha = 0
        }
        */
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        /*
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
        */
    }
    
    func animateElements(isOn: Bool) {
        
        if (isOn) {
            self.isFreqCellSelected = true
            self.freqPicker.alpha = 1
            self.freqPickerHeaderView.alpha = 1
            //tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        } else {
            self.isFreqCellSelected = false
            self.freqPicker.alpha = 0
            self.freqPickerHeaderView.alpha = 0
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        self.placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
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
    
    func setFirebaseRequest(destination: GMSPlace) {
        print("Send to FB: Place name: \(destination.name)")
        print("Send: Place address: \(destination.formattedAddress)")
        print("Send: Place attributions: \(destination.attributions)")
        self.destLat = destination.coordinate.latitude
        self.destLong = destination.coordinate.longitude
        self.destName = destination.formattedAddress as NSString!
    }
}

extension RideRequestTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerRows[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.pickerComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerRows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = self.pickerRows[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightRegular)])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
}

extension RideRequestTableViewController: GMSAutocompleteResultsViewControllerDelegate {
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
