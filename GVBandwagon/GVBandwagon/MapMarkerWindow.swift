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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 100, alpha: 0.8)
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        //create vertical stack view centered vertically and leading/trailing edges to view.
        let labelArray = [nameLabel, destLabel, rateLabel, acceptButton, declineButton] as [Any]
        let stackView = UIStackView(arrangedSubviews: labelArray as! [UIView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        
        //self.addSubview(nameLabel)
        //self.addSubview(destLabel)
        //self.addSubview(rateLabel)
        //self.addSubview(acceptButton)
        //self.addSubview(declineButton)
        //self.translatesAutoresizingMaskIntoConstraints = false // Causes funkyness with infoWindow.
        
        let margins = self.layoutMarginsGuide
        
        // Drawing code
        
        //nameLabel.center = CGPoint(x: 50, y: 0)
        //nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.text = "Name"
        
        
        //destLabel.center = CGPoint(x: 100, y: 30)
        //destLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //destLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        //destLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30).isActive = true
        
        //let y = NSLayoutConstraint(item: destLabel, attribute: .topMargin, relatedBy: .equal, toItem: nameLabel, attribute: .bottomMargin, multiplier: 1.0, constant: 0)
        //self.addConstraint(y)
        
        destLabel.textColor = UIColor.white
        destLabel.textAlignment = .center
        destLabel.text = "Downtown"
        
        
        //rateLabel.center = CGPoint(x: 100, y: 50)
        //rateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //rateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        //rateLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 60).isActive = true
        rateLabel.textColor = UIColor.white
        rateLabel.textAlignment = .center
        rateLabel.text = "$5"
        
        //acceptButton.center = CGPoint(x: 50, y: 75)
        //acceptButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //acceptButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 2).isActive = true
        //acceptButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 90).isActive = true
        
        //let y = NSLayoutConstraint(item: acceptButton, attribute: .topMargin, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1.0, constant: 75)
        //self.addConstraint(y)
        
        acceptButton.setTitleColor(UIColor.white, for: .normal)
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.titleLabel?.textAlignment = .center
        
        //declineButton.center = CGPoint(x: 150, y: 75)
        //declineButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        //declineButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
        declineButton.setTitleColor(UIColor.white, for: .normal)
        declineButton.titleLabel?.textAlignment = .center
        declineButton.setTitle("Decline", for: .normal)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        //let margins = self.layoutMarginsGuide
        
        //self.addSubview(acceptButton)
        
        //acceptButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 90).isActive = true
    }
}
