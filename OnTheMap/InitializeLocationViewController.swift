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
    
    var activityIndicator: UIActivityIndicatorView!
    var keyboardOnScreen = false
    var originalButtonText: String?
    
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func findOnTheMapButtonPressed(_ sender: Any) {
        if let searchText = locationTextField.text, searchText != "" {
            showLoading()
            geocodeSearchText(searchText)
        } else {
            Helper.handleError("Location is required.", viewController: self)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
         dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
    }

    func geocodeSearchText(_ searchText: String) {
        CLGeocoder().geocodeAddressString(searchText) { (placemark, error) in
            performUIUpdatesOnMain {
                self.hideLoading()
                (error == nil) ? self.handleSuccess(placemark!) : Helper.handleError(String("There was a problem finding your location"), viewController: self)
            }
        }
    }
    
    func handleSuccess(_ placemark: [CLPlacemark]) {
        let saveLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "SaveLocationViewController") as! SaveLocationViewController
        saveLocationViewController.searchResultPlacemarks = placemark
        self.present(saveLocationViewController, animated: true, completion: nil)
    }
}


extension InitializeLocationViewController {
    
    func showLoading() {
        originalButtonText = findOnTheMapButton.titleLabel?.text
        findOnTheMapButton.setTitle("", for: .normal)
        showSpinning()
    }
    
    func hideLoading() {
        findOnTheMapButton.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func showSpinning() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        findOnTheMapButton.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: findOnTheMapButton, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yCenterConstraint = NSLayoutConstraint(item: findOnTheMapButton, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        findOnTheMapButton.addConstraint(xCenterConstraint)
        findOnTheMapButton.addConstraint(yCenterConstraint)
    }
    
    
}

extension InitializeLocationViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen && Helper.orientationIsLandscape() {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen && Helper.orientationIsLandscape() {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
    }
    
}
