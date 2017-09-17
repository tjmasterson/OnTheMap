//
//  MapPeopleViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import MapKit

class MapPeopleViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "RefreshPeopleData"), object: nil)
    }
    
    func refresh() {
        showLoading()
         mapView.reloadInputViews()
    
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        for person in OTMData.shared.people {
            let lat = CLLocationDegrees(person.latitude)
            let lng = CLLocationDegrees(person.longitude)
            let fullName = "\(person.firstName) \(person.lastName)"
            let mediaURL = person.mediaURL
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = fullName
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }

        mapView.showAnnotations(annotations, animated: true)
        hideLoading()
    }

}

extension MapPeopleViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared 
            if let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) {
                app.open(url) { (success) in
                    if !success {
                        performUIUpdatesOnMain {
                            Helper.handleError("Link is not a valid url.", viewController: self)
                        }
                    }
                }
            } else {
                Helper.handleError("No link provided for this entry.", viewController: self)
            }
        }
    }

}

extension MapPeopleViewController {
    func showLoading() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.blue
        view.alpha = CGFloat(0.5)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        view.alpha = CGFloat(1.0)
        activityIndicator.stopAnimating()
    }
    
}

