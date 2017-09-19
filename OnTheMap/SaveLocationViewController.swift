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
    var userCoordinate: CLLocationCoordinate2D?
    var userMapString: String?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareLinkTextField: UITextField!
    
    @IBAction func submitLocationPressed(_ sender: Any) {
        if let link = shareLinkTextField.text {
            guard let latitude = userCoordinate?.latitude, let longitude = userCoordinate?.longitude else {
                Helper.handleError("There was a problem finding your latitude or longitude of your location, please try again!", viewController: self)
                return
            }
            
            let parameters: [String: AnyObject] = [
                ParseClient.JSONBodyKeys.UserMediaURL: link,
                ParseClient.JSONBodyKeys.UserMapString: userMapString!,
                ParseClient.JSONBodyKeys.UserLatitude: latitude,
                ParseClient.JSONBodyKeys.UserLongitude: longitude] as [String: AnyObject]
            
            overwriteOrPostPersonLocation(parameters)
        } else {
            performUIUpdatesOnMain { Helper.handleError("Link to share is required!", viewController: self) }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareLinkTextField.delegate = self
        plotPinOnMap()
    }
    
    func plotPinOnMap() {
        /*
         * This will almost always be an array with a length of one, 
         * but guard against multiple entries by always popping off the last element
         * and storing the coordinate, and name in a property variable
         */
        if let placemark = searchResultPlacemarks.last {
            userMapString = "\(String(describing: placemark.locality!)), \(String(describing: placemark.administrativeArea!))"
            if let location = placemark.location {
                let coordinate = location.coordinate
                userCoordinate = coordinate
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                let coordinateSpan = MKCoordinateSpanMake(0.5, 0.5)
                let region = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
                
                mapView.setRegion(region, animated: true)
                mapView.addAnnotation(annotation)
            } else {
                Helper.handleError("There was an error finding your location, please try again!", viewController: self)
            }
        } else {
            Helper.handleError("There was an error finding your location, please try again!", viewController: self)
        }
    }
    
    func overwriteOrPostPersonLocation(_ parameters: [String: AnyObject]) {
        if OTMData.shared.overwriteExistingLocation {
            ParseClient.sharedInstance().updatePersonLocation(parameters) { (results, error) in
                performUIUpdatesOnMain {
                    (error == nil) ? self.handleSuccess() : Helper.handleError((error?.domain)!, viewController: self)
                }
            }
        } else {
            ParseClient.sharedInstance().createPersonLocation(parameters) { (results, error) in
                performUIUpdatesOnMain {
                    (error == nil) ? self.handleSuccess() : Helper.handleError((error?.domain)!, viewController: self)
                }
            }
        }
    }
    
    func handleSuccess() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshPeopleData"), object: nil)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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

extension SaveLocationViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        if shareLinkTextField.isFirstResponder {
            shareLinkTextField.resignFirstResponder()
        }
    }
    
}










































