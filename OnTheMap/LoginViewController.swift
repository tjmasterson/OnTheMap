//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let parameters: [String: AnyObject] = [
            OTMClient.JSONBodyValues.Username: emailTextField.text! as AnyObject,
            OTMClient.JSONBodyValues.Password: passwordTextField.text! as AnyObject,
        ]
        
        let _ = OTMClient.sharedInstance().taskForCredentialLoginMethod(parameters: parameters) { (success, errorString) in
            performUIUpdatesOnMain {
                if (success != nil) {
                    print("self.completeCredentialLogin()")
                } else {
                    print("self.displayError(errorString)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        shouldLoginBeDisabled()
    }
    
    func shouldLoginBeDisabled() {
        if emailTextField.hasText, passwordTextField.hasText {
            loginButton.isEnabled = true
        }
        loginButton.isEnabled = false
    }

    func completeCredentialLogin() {
        
    }
    
    func displayError() {
        
    }

}

extension LoginViewController: UITextFieldDelegate {
    // MARK: - Text Field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        shouldLoginBeDisabled()
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        shouldLoginBeDisabled()
        textField.resignFirstResponder()
        return true
    }
    
}
