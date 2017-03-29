//
//  RateUserViewController.swift
//  Pods
//
//  Created by Nicolas Heady on 3/29/17.
//
//

import UIKit

class RateUserViewController: UIViewController {

    @IBOutlet var ratingImageView: UIImageView!
    
    var ratingWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingWidth = ratingImageView.frame.width

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRatingTapped(_ sender: UITapGestureRecognizer) {
        
        let x = sender.location(in: self.ratingImageView).x
        
        print("Width: \(self.ratingWidth)")
        print("x: \(x)")
        
        if (self.ratingWidth / x > 1) {
            // Two stars
            self.ratingImageView.image = #imageLiteral(resourceName: "fivestars")
        }
        if (self.ratingWidth / x > 1.2) {
            // Two stars
            self.ratingImageView.image = #imageLiteral(resourceName: "fourstars")
        }
        if (self.ratingWidth / x > 1.6) {
            // Three stars
            self.ratingImageView.image = #imageLiteral(resourceName: "threestars")
        }
        if (self.ratingWidth / x > 2.5) {
            // Four stars
            self.ratingImageView.image = #imageLiteral(resourceName: "twostars")
        }
        if (self.ratingWidth / x > 5) {
            // Five stars
            self.ratingImageView.image = #imageLiteral(resourceName: "onestar")
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

}
