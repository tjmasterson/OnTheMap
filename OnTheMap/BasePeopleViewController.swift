//
//  BasePeopleViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/6/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class BasePeopleViewController: UITabBarController {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        fetchPeopleData()
    }
    
    @IBAction func addPinButtonPressed(_ sender: Any) {
        let initializeLocationViewController = storyboard!.instantiateViewController(withIdentifier: "InitializeLocationViewController") as! InitializeLocationViewController
       present(initializeLocationViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPeopleData()
    }
    
    func fetchPeopleData() {
        ParseClient.sharedInstance().getPeople() { (people, error) in
            if let people = people {
                performUIUpdatesOnMain {
                    OTMData.shared.people = people
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshPeopleData"), object: self)
                }
            }
        }
    }

}
