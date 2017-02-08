//
//  RideViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 2/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class RideViewController: UIViewController {

    @IBOutlet var fromContainerView: UIView!
    @IBOutlet var fromView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: 0)
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
    
    @IBAction func fromTapped(_ sender: Any) {
        print("from tapped")
        
        var frameHeight: CGFloat = 0
        if (self.fromContainerView.frame.height == 0) {
            frameHeight = 250
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.fromContainerView.frame = CGRect(x: self.fromContainerView.frame.origin.x, y: self.fromContainerView.frame.origin.y, width: self.fromContainerView.frame.width, height: frameHeight)
        }, completion: { (Bool) -> Void in
            // what to do when completed animation.
        })
        
    }
}
