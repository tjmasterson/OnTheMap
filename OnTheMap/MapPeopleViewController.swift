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

    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "RefreshPeopleData"), object: nil)
    }
    
    func refresh() {
        if (!mapView.annotations.isEmpty) {
            mapView.removeAnnotations(mapView.annotations)
        }
        
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
            
            // not really sure why I don't need to keep this...
            // self.mapView.addAnnotation(annotation)
        }

        mapView.showAnnotations(annotations, animated: true)
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


