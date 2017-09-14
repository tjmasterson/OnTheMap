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
        OTMData.shared.userHasPostedLocation ? confirmLocationOverwrite() : trasitionToPinCreation()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UdacityClient.sharedInstance().taskForCredentialLogoutMethod() { (results, error) in
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(initialViewController, animated: true, completion: nil)
        }
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
    
    func transitionAndStagePinRemoval(action: UIAlertAction? = nil) {
        OTMData.shared.overwriteExistingLocation = true
        trasitionToPinCreation()
    }
    
    func trasitionToPinCreation() {
        let initializeLocationViewController = storyboard!.instantiateViewController(withIdentifier: "InitializeLocationViewController") as! InitializeLocationViewController
        present(initializeLocationViewController, animated: true, completion: nil)
    }
    
    func confirmLocationOverwrite() {
        let message = "You have already posted your location. Would you like to overwrite it?"
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: self.transitionAndStagePinRemoval))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
