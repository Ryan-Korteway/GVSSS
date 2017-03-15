//
//  MapMarkerWindow.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 3/15/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class MapMarkerWindow: UIView {
    
    let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    let destLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    let rateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    let acceptButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    let declineButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 20))

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        nameLabel.center = CGPoint(x: 0, y: 0)
        nameLabel.textAlignment = .center
        nameLabel.text = "Name"
        
        destLabel.center = CGPoint(x: 0, y: 20)
        destLabel.textAlignment = .center
        destLabel.text = "Name"
        
        rateLabel.center = CGPoint(x: 0, y: 40)
        rateLabel.textAlignment = .center
        rateLabel.text = "$5"
        
        acceptButton.center = CGPoint(x: 0, y: 60)
        acceptButton.setTitle("Accept", for: .normal)
        
        declineButton.center = CGPoint(x: 100, y: 60)
        declineButton.setTitle("Decline", for: .normal)
        
        self.addSubview(nameLabel)
        self.addSubview(destLabel)
        self.addSubview(rateLabel)
        self.addSubview(acceptButton)
        self.addSubview(declineButton)
    }
    

}
