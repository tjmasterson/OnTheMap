//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var activityIndicator: UIActivityIndicatorView!
    var originalButtonText: String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        showLoading()
        
//        let parameters: [String: AnyObject] = [
//            UdacityClient.JSONBodyKeys.Username: emailTextField.text! as AnyObject,
//            UdacityClient.JSONBodyKeys.Password: passwordTextField.text! as AnyObject
//        ]
        let parameters: [String: AnyObject] = [
            UdacityClient.JSONBodyKeys.Username: "taylor.j.masterson@gmail.com" as AnyObject,
            UdacityClient.JSONBodyKeys.Password: "Elmstreet1127" as AnyObject,
            ]
        let _ = UdacityClient.sharedInstance().taskForCredentialLoginMethod(parameters: parameters) { (success, errorString) in
            performUIUpdatesOnMain {
                self.hideLoading()
                
                if (success != nil) {
                    self.completeCredentialLogin()
                } else {
                    print("self.displayError(errorString)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func shouldLoginBeDisabled() {
        if emailTextField.hasText, passwordTextField.hasText {
            loginButton.isEnabled = true
        }
        loginButton.isEnabled = false
    }

    func completeCredentialLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    // MARK: - Text Field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginViewController {
    
    func showLoading() {
        originalButtonText = loginButton.titleLabel?.text
        loginButton.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        loginButton.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
    
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        loginButton.addConstraint(xCenterConstraint)
        loginButton.addConstraint(yCenterConstraint)
    }
}
