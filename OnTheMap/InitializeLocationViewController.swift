//
//  InitializeLocationViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/9/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import MapKit

class InitializeLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func findOnTheMapButtonPressed(_ sender: Any) {
        if let searchText = locationTextField.text, searchText != "" {
            geocodeSearchText(searchText)
        } else {
            Helper.handleError("Location is required.", viewController: self)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
         self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func geocodeSearchText(_ searchText: String) {
        CLGeocoder().geocodeAddressString(searchText) { (placemark, error) in
            performUIUpdatesOnMain {
                (error == nil) ? self.handleSuccess(placemark!) : Helper.handleError(String(describing: error!), viewController: self)
            }
        }
    }
    
    func handleSuccess(_ placemark: [CLPlacemark]) {
        let saveLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "SaveLocationViewController") as! SaveLocationViewController
        saveLocationViewController.searchResultPlacemarks = placemark
        self.present(saveLocationViewController, animated: true, completion: nil)
    }

}
