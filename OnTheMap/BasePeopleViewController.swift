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
    }
    @IBAction func addPinButtonPressed(_ sender: Any) {
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    func refresh() {
        
        MapPeopleViewController().refresh()
        ListPeopleViewController().refresh()

    }
    
    func addPersonToMap() {
        
    }
    
    func logout() {
        
    }

}
