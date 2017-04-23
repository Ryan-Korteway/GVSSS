//
//  GVBNotificationDelegate.swift
//  GVBandwagon
//
//  Created by Blaze on 2/25/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase

class GVBNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let localDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // THE ACTIONS NEED TO CHANGE THE APP DELEGATES TIMER STATES.
        
        // Determine the user action
        print(response.actionIdentifier)
        
        let notification : UNNotificationContent = response.notification.request.content
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action") //havent triggered this one yet so far.
        
        case UNNotificationDefaultActionIdentifier:
            print("Default") //this is what gets called if you just tap on the notification, usually just opens the app to somewhere, probably we would want to put in some view controller refresh logic into here perhaps? call open observers perhaps?
        
        case "offer":
            
            //here we would offer the rider a ride by populating the proper fields/path in that riders profile.
            
            let ref = FIRDatabase.database().reference().child("users/\(notification.userInfo["uid"]!)/rider/offers/immediate/")
            localDelegate.offeredID = notification.userInfo["uid"]! as! String
            let user = FIRAuth.auth()!.currentUser!
            
            //idk about user.displayName here.
            
            //maybe venmo id is a global var in app delegate with a getter/setter for moments like this.
            ref.child("\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": localDelegate.getVenmoID(), "origin": notification.userInfo["origin"], "destination": notification.userInfo["destination"], "rate": notification.userInfo["rate"], "accepted" : 0, "repeats": notification.userInfo["repeats"], "date": notification.userInfo["date"], "destinationName": notification.userInfo["destinationName"]]) //value set needs to be all of our info for the snapshot.
            
            //see even here we are passing back to the rider their own locations (origin and dest)...
            localDelegate.changeDriverStatus(status: "offer")
            localDelegate.changeMode(mode: "driver")
            print("ride offered") //this one is if you hit the snooze button
            
        case "accept": //paths are off but the actions themselves work. to fix on my own at some point. need to also change statuses etc.
            
            //here we would accept the riders offer. doing so by making their offer as true, before deleting the whole branch, and making a new branch called accepted, which would contain the necessary info for the rider and his updated lats/longs
            
            let user = FIRAuth.auth()!.currentUser!
            
            let topRef = FIRDatabase.database().reference()
            
            topRef.child("requests/immediate/\(user.uid)").removeValue()
            
            let ref = FIRDatabase.database().reference().child("users/\(user.uid)/rider/")
            
            ref.child("offers/immediate/\(notification.userInfo["uid"]!)/accepted").setValue(1); //set the accepted drivers accepted value to 1.

            ref.child("offers/immediate/\(notification.userInfo["uid"]!)").observeSingleEvent(of: .value, with: { snapshot in
                let dictionary: NSDictionary = snapshot.value! as! NSDictionary
                ref.child("offers/accepted/immediate/driver/\(notification.userInfo["uid"]!)").setValue(dictionary) //create an accepted branch of the riders table
                
                let localDelegate = UIApplication.shared.delegate as! AppDelegate
                localDelegate.riderStatus = "accepted"
                
                let newOrigin = ["lat": localDelegate.ourlat, "long": localDelegate.ourlong, "address": localDelegate.ourAddress] as [String : Any]
                
                ref.child("offers/accepted/immediate/rider/\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": "none", "origin": newOrigin, "destination": dictionary.value(forKey: "destination")! as! NSDictionary, "rate" : dictionary.value(forKey: "rate") as! NSString, "accepted": 1, "repeats": "none", "date": dictionary.value(forKey: "date") as! NSString, "destinationName": dictionary.value(forKey: "destinationName")! as! NSString])
                
                print("we have accepted")
                
                ref.child("offers/immediate/").removeValue() //remove the offers immediate branch from the riders account so that the drivers are able to observe the destruction and if they were selected or not.
            
                //history set up here.
                let ourID = FIRAuth.auth()!.currentUser!.uid
                topRef.child("users/\(ourID)/history/\(dictionary.value(forKey: "destinationName")!)\(dictionary.value(forKey: "date"))/").setValue(dictionary)
                
//            ref.child("accepted/immediate/").setValue(notification.userInfo) //create an accepted branch of the riders table
//            
//            ref.child("offers/immediate/").removeValue() //remove the offers immediate branch from the riders account so that the drivers are able to observe the destruction and if they were selected or not.
            
            localDelegate.changeRiderStatus(status: "accepted")
            
                print("ride accepted")  //this one is the delete button.
            })
        case "dismiss":
            print("notification dismissed")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
