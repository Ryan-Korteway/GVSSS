//
//  cellFile.swift
//  GVBandwagon
//
//  Created by Blaze on 2/25/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//
//  Explanation of the copyright below. The struct and init in this class was based off of
//  starter/tutorial material given here: https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
//  and modified to shape our particular needs. Given the source and the changing of the code, the additional copyright
//  comment below was necessary.

/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Firebase

//We really should add dates to this...

//This is the structure that will be made each time a rider makes a request and the data
//is sent to firebase and then is being pulled back from firebase to some other users phone.
struct cellItem {
    
    let uid: String
    let name: String
    let venmoID: String
    let origin: NSDictionary
    let destination: NSDictionary //going to need destination strings added to struct at some point.
    let destinationName: NSString
    let rate: NSNumber
    var accepted: NSInteger
    var repeats: NSString
    var date: NSString
    
    init(snapshot: FIRDataSnapshot) {
        //uid = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String ?? snapshot.key 
        name = snapshotValue["name"] as! String
        venmoID = snapshotValue["venmoID"] as! String
        rate = snapshotValue["rate"] as! NSNumber
        origin = snapshotValue["origin"] as! NSDictionary
        destination = snapshotValue["destination"] as! NSDictionary
        destinationName = snapshotValue["destinationName"] as! NSString
        accepted = snapshotValue["accepted"] as! NSInteger //if its set to 0, its false/no ride acceptance, else it is 1 and ride accepted.
        repeats = snapshotValue["repeats"] as! NSString
        date = snapshotValue["date"] as! NSString
    }
    
    init(start: NSDictionary) {
        uid = start.value(forKey: "uid") as! String
        name = start.value(forKey: "name") as! String
        venmoID = start.value(forKey: "venmoID") as! String //needs to be added automatically with FIRAuth.auth().currentUser.email etc.
        rate = start.value(forKey: "rate") as! NSNumber
        origin = start.value(forKey: "origin") as! NSDictionary //should be a dictionary of lats and longs
        destination = start.value(forKey: "destination") as! NSDictionary //should be a dictionary of lats and longs
        accepted = start.value(forKey: "accepted") as! NSInteger //if its set to 0, its false/no ride acceptance, else it is 1 and ride accepted.
        destinationName = start.value(forKey: "destinationName") as! NSString
        repeats = start.value(forKey: "repeats") as! NSString
        date = start.value(forKey: "date") as! NSString
    }
    
    // removed duplicate key: "rate": rate,
    func toAnyObject() -> Any {
        return [
            "name": name,
            "uid": uid,
            "venmoID": venmoID,
            "rate": rate,
            "origin" : origin,
            "destination": destination,
            "destinationName": destinationName,
            "accepted" : accepted,
            "repeats": repeats,
            "date": date
        ]
    }
    
}

//  These are the protocols that the rider and driver view controllers must follow so that they can either create a local 
//  notification talking about the ride request or offer being accepted. Aside from local notifications, actions to notify the user
//  of changes to their request status could be to see the map change from "all active drivers" to the "offering drivers" to "The accepted driver" etc.
protocol rider_notifications {
    func ride_offer(item: cellItem) -> Void
    func ride_accept(item: NSDictionary) -> Void
    func isRider() -> Bool
    func isDriver() -> Bool
}

protocol driver_notifications {
    func ride_accept(item: cellItem) -> Void
    func white_ride(item: cellItem) -> Void
    func ride_request(item: cellItem) -> Void //idk about feeding these function declarations items of type cellItem...
    func isRider() -> Bool
    func isDriver() -> Bool
}
