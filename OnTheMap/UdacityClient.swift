//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/10/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func taskForCredentialLoginMethod(email: String, password: String, completionHandlerForCredentialLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void ) -> Void {

        let bodyData = [
            UdacityClient.JSONBodyKeys.AuthWrapper: [
                UdacityClient.JSONBodyKeys.Username: email,
                UdacityClient.JSONBodyKeys.Password: password
            ]
        ] as [String: AnyObject]
        
        let _ = taskForPOSTMethod(UdacityClient.Methods.Auth, jsonBodyData: bodyData) { (results, error) in
            if let error = error {
                completionHandlerForCredentialLogin(nil, error)
            } else {
                if let results = results {
                    self.parseAndSaveLoginDetails(results as! [String: AnyObject], completionHandlerForSaveLoginDetails: completionHandlerForCredentialLogin)
                } else {
                    completionHandlerForCredentialLogin(nil, NSError(domain: "taskForCredentialLoginMethod parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse taskForCredentialLoginMethod results"]))
                }
            }
        }
    }
    
    func taskForCredentialLogoutMethod(completionHandlerForCredentialLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void ) -> Void {
        
        let _ = taskForDeleteMethod(UdacityClient.Methods.Logout) { (results, error) in
            if let error = error {
                completionHandlerForCredentialLogin(nil, error)
            } else {
                if let results = results {
                    completionHandlerForCredentialLogin(results, nil)
                } else {
                    completionHandlerForCredentialLogin(nil, NSError(domain: "taskForCredentialLoginMethod parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse taskForCredentialLoginMethod results"]))
                }
            }
        }
    }
}
