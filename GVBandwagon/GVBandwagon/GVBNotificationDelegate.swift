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
    
    let localDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
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
            ref.child("\(user.uid)").setValue(["name": user.displayName!, "uid": user.uid, "venmoID": localDelegate.getVenmoID(), "origin": notification.userInfo["origin"], "destination": notification.userInfo["destination"], "rate": notification.userInfo["rate"], "accepted" : 0, "repeats": notification.userInfo["repeats"], "duration": notification.userInfo["duration"], "destinationName": notification.userInfo["destinationName"]]) //value set needs to be all of our info for the snapshot.
            
            //see even here we are passing back to the rider their own locations (origin and dest)...
            localDelegate.changeDriverStatus(status: "offer")
            localDelegate.changeMode(mode: "driver")
            print("ride offered") //this one is if you hit the snooze button
            
        case "accept":
            
            //here we would accept the riders offer. doing so by making their offer as true, before deleting the whole branch, and making a new branch called accepted, which would contain the necessary info for the rider and his updated lats/longs
            
            let user = FIRAuth.auth()!.currentUser!
            
            let ref = FIRDatabase.database().reference().child("users/\(user.uid)/rider/")
            
            ref.child("offers/immediate/\(notification.userInfo["uid"]!)/accepted").setValue(1); //set the accepted drivers accepted value to 1.

            ref.child("accepted/immediate/").setValue(notification.userInfo) //create an accepted branch of the riders table
            
            ref.child("offers/immediate/").removeValue() //remove the offers immediate branch from the riders account so that the drivers are able to observe the destruction and if they were selected or not.
            
            localDelegate.changeRiderStatus(status: "accepted")
            
            //if accepted, then the driver knows to start a timer to update the lat longs in the users rider offers acepted path.
            
            print("ride accepted")  //this one is the delete button.
        case "dismiss":
            print("notification dismissed")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
