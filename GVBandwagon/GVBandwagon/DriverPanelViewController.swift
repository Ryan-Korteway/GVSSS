//
//  DriverPanelViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class DriverPanelViewController: UIViewController {

    @IBOutlet var goOnlineSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.goOnlineSwitch.setOn(false, animated: false)
        self.goOnlineSwitch.addTarget(self, action: #selector(switchIsChanged(mySwitch:)), for: .valueChanged)
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if mySwitch.isOn {
            appDelegate.toggleRightDrawer(sender: mySwitch, animated: true)
            let centerVC = appDelegate.centerViewController as? UITabBarController
            let driveVC = centerVC?.childViewControllers[0] as? DriveViewController
            driveVC?.goOnlineLabelBtnTapped(mySwitch)
        } else {
            // Remove driver from active driver list
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
