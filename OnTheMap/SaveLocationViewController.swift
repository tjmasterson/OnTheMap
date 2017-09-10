//
//  SaveLocationViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/9/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import MapKit

class SaveLocationViewController: UIViewController {

    var searchResultPlacemarks: [CLPlacemark] = [CLPlacemark]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareLinkTextField: UITextField!
    
    
    @IBAction func submitLocationPressed(_ sender: Any) {
        if let link = shareLinkTextField.text {
            var parameters = [String: AnyObject]()
            parameters["link"] = link as AnyObject
            // "mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}"
            ParseClient.sharedInstance().createPersonLocation(parameters) { (results, error) in
                performUIUpdatesOnMain {
                    (error == nil) ? self.handleSuccess() : self.handleError((error?.domain)!)
                }
            }
        } else {
            performUIUpdatesOnMain { self.handleError("Link to share is required!") }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotPinOnMap()
    }
    
    func plotPinOnMap() {
        for placemark in searchResultPlacemarks {
            if let location = placemark.location {
                let coordinate = location.coordinate
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            } else {
                handleError("There was an error finding your location, please try again!")
            }
        }
    }
    
    func handleSuccess() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshPeopleResults"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleError(_ errorString: String) {
        let alert = UIAlertController(title: "", message: errorString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension SaveLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, completionHandler: nil)
            }
        }
    }
    
}
