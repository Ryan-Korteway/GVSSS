//
//  ContainerViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 1/28/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

protocol ContainerDelegate {
    var menuShown: Bool {get}
    func showMenu()
    func hideMenu()
}


class ContainerViewController: UIViewController, ContainerDelegate {
    
    var menuShown = false
    
    var rideViewController: FirstViewController! = nil
    var driveViewController: UIViewController! = nil
    var menuViewController: MenuTableViewController! = nil
    //var accountViewController:
    
    var leftMenu: UIViewController? {
        // May not need willSet because I will always want leftViewController to be "set"
        willSet{
            if self.leftMenu != nil {
                if self.leftMenu!.view != nil {
                    self.leftMenu!.view!.removeFromSuperview()
                }
                self.leftMenu!.removeFromParentViewController()
            }
        }
        
        didSet{
            self.view!.addSubview(self.leftMenu!.view)
            self.addChildViewController(self.leftMenu!)
            
            // Sets initial size to basically invisible:
            self.leftMenu!.view.frame = CGRect(x: self.view.frame.origin.x - 225, y: self.view.frame.origin.y, width: 225, height: self.view.frame.height)
        }
    }
    
    var rightViewController: FirstViewController? {
        willSet {
            if self.rightViewController != nil {
                if self.rightViewController!.view != nil {
                    self.rightViewController!.view!.removeFromSuperview()
                }
                self.rightViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            // Opens the new view with smaller frame so side menu is still visible:
            if self.menuShown == true {
                //self.rightViewController!.view.frame = CGRect(x: self.view.frame.origin.x + 235, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            }
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
            
            self.rightViewController!.containerDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Instantiates the view controllers this Container View Controller will need to access:
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.menuViewController = storyboard.instantiateViewController(withIdentifier: "menuTableViewController") as! MenuTableViewController
        self.rideViewController = storyboard.instantiateViewController(withIdentifier: "rideViewController") as! FirstViewController
        
        self.rightViewController = self.rideViewController
        self.leftMenu = self.menuViewController

        self.menuViewController.containerDelegate = self
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.menuViewController = storyboard.instantiateViewController(withIdentifier: "menuTableViewController") as! MenuTableViewController
        self.rideViewController = storyboard.instantiateViewController(withIdentifier: "rideViewController") as! FirstViewController
        
        self.rightViewController = self.rideViewController
        self.leftMenu = self.menuViewController
        
    }
     */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMenu!.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.leftMenu!.view.frame.width, height: self.leftMenu!.view.frame.height)
        }, completion: { (Bool) -> Void in
            self.menuShown = true
        })
        self.leftMenu!.view.layer.shadowOpacity = 0.6
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMenu!.view.frame = CGRect(x: self.view.frame.origin.x - self.leftMenu!.view.frame.width, y: self.view.frame.origin.y, width: self.leftMenu!.view.frame.width, height: self.leftMenu!.view.frame.height)
        }, completion: { (Bool) -> Void in
            self.rightViewController!.view.layer.shadowOpacity = 0.0
            self.menuShown = false
        })
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
