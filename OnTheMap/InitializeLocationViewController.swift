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
            print("error no search text")
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
                (error == nil) ? self.handleSuccess(placemark!) : self.handleError(String(describing: error!))
            }
        }
    }
    
    func handleSuccess(_ placemark: [CLPlacemark]) {
        let saveLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "SaveLocationViewController") as! SaveLocationViewController
        saveLocationViewController.searchResultPlacemarks = placemark
        self.present(saveLocationViewController, animated: true, completion: nil)
    }
    
    func handleError(_ errorString: String) {
        let alert = UIAlertController(title: "", message: errorString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
