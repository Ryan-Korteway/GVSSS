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
    @IBOutlet var submitButton: UIButton!
    
    var ratingWidth: CGFloat!
    var newRating = 1
    var shadowLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingWidth = ratingImageView.frame.width

        // Submit Button
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: self.submitButton.bounds, cornerRadius: 5).cgPath
            shadowLayer.fillColor = UIColor.blue.cgColor
            
            self.submitButton.layer.insertSublayer(self.shadowLayer, at: 0)
            
            self.submitButton.setTitleColor(UIColor.white, for: .normal)
        }
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
            self.newRating = 5
        }
        if (self.ratingWidth / x > 1.2) {
            // Two stars
            self.ratingImageView.image = #imageLiteral(resourceName: "fourstars")
            self.newRating = 4
        }
        if (self.ratingWidth / x > 1.6) {
            // Three stars
            self.ratingImageView.image = #imageLiteral(resourceName: "threestars")
            self.newRating = 3
        }
        if (self.ratingWidth / x > 2.5) {
            // Four stars
            self.ratingImageView.image = #imageLiteral(resourceName: "twostars")
            self.newRating = 2
        }
        if (self.ratingWidth / x > 5) {
            // Five stars
            self.ratingImageView.image = #imageLiteral(resourceName: "onestar")
            self.newRating = 1
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
