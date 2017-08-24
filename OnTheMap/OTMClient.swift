//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class OTMClient: NSObject {

    // MARK: Properties
    
    // shared session
    var session = URLSession.shared

    
    // authentication state
    var sessionID: String? = nil
    var userID: String? = nil
    
    
    // MARK: Initializers 
    
    override init() {
        super.init()
    }
    
    func taskForCredentialLoginMethod(parameters: [String: AnyObject], completionHandlerForCredentialLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void ) -> Void {

        postCredentials(parameters: parameters) { (success, errorString) in
            if (success != nil) {
                self.parseAndSaveLoginDetails(success as! [String: AnyObject])
            }
            completionHandlerForCredentialLogin(success, errorString)
        }

    }
    
    func postCredentials(parameters: [String: AnyObject], completionHandlerForPostCredentials: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void ) -> Void {
        
        let placeHolder = [String: AnyObject]()
        
        let username: String = String(describing: parameters[OTMClient.JSONBodyValues.Username]!)
        let password: String = String(describing: parameters[OTMClient.JSONBodyValues.Password]!)
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        let _ = taskForPOSTMethod(OTMClient.Constants.AuthURL, parameters: placeHolder, jsonBody: jsonBody) { (results, error) in
            if let error = error {
                completionHandlerForPostCredentials(nil, error)
            } else {
                if let results = results {
                    completionHandlerForPostCredentials(results, nil)
                } else {
                    completionHandlerForPostCredentials(nil, NSError(domain: "postCredentials parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postCredentials results"]))
                }
            }
        }


    }
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        var parametersWithApiKey = parameters
        
        
//        let request = NSMutableURLRequest(url: tmdbURLFromParameters(parametersWithApiKey, withPathExtension: method))
        
        let request = NSMutableURLRequest(url: URL(string: method)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard (data != nil) else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func parseAndSaveLoginDetails(_ data: [String:AnyObject]) {
        guard let account = data[OTMClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
            print("account error")
            return
        }

        guard let userID = account[OTMClient.JSONResponseKeys.UserID] as? String else {
            print("user id error")
            return
        }
        
        guard let session = data[OTMClient.JSONResponseKeys.Session] as? [String: AnyObject] else {
            print(" session error")
            return
        }
        
        guard let sessionID = session[OTMClient.JSONResponseKeys.SessionID] as? String else {
            print(" session id error")
            return
        }
        
        self.userID = userID
        self.sessionID = sessionID
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
