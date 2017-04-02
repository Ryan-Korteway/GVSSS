//
//  HelpViewController.swift
//  GVBandwagon
//
//  Created by Nicolas Heady on 2/7/17.
//  Copyright © 2017 Nicolas Heady. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "howToRideSegue" {
            if let vc = segue.destination as? HelpPageViewController {
                vc.imageNames = ["ride1", "ride2", "ride4"]
            }
            
        }
    }
    
    @IBAction func onDoneTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }


}
