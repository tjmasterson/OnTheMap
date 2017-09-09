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
    var defaultGetPeopleParams = [OTMClient.ParameterKeys.Limit: OTMClient.ParameterValues.Limit,
                                  OTMClient.ParameterKeys.Order: OTMClient.ParameterValues.Order] as [String: AnyObject]
    
    
    // MARK: Initializers 
    
    override init() {
        super.init()
    }
    
    
    func getPeople(_ parameters: [String: AnyObject] = [String:AnyObject](),
                   completionHandlerForGetPeople: @escaping (_ result: [OTMPerson]?, _ error: NSError?) -> Void) {
        /*
         - Get the last x number locations that were updated
         - Default number of results set to 100
         - Functionality does not support an override to the default number of results, but maybe down the road...
        */
        
        let parametersWithOptions = combine(defaultGetPeopleParams, with: parameters)
        
        let _ = taskForGETMethod(OTMClient.Methods.People, parameters: parametersWithOptions) { (results, error) in

            if let error = error {
                completionHandlerForGetPeople(nil, error)
            } else {
                if let results = results?[OTMClient.JSONResponseKeys.PeopleResults] as? [[String:AnyObject]] {
                    let people = OTMPerson.peopleFromResults(results)
                    completionHandlerForGetPeople(people, nil)
                } else {
                    completionHandlerForGetPeople(nil, NSError(domain: "getPeople parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPeople"]))
                }
            }
        }
        
    }
    
    func createPersonLocation(_ parameters: [String: AnyObject] = [String: AnyObject](),
                              completionHandlerForCreatePerson: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
    }
    
/*  func getPerson() {
        
    }

    
    func updatePersonLocation() {
        
    }
*/
    
    func taskForGETMethod(_ method: String, parameters: [String: AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = otmParseURLFromParameters(parameters, withPathExtension: method)
        let request = otmRequestWithApiKeys(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Make sure we don't get an error from the api
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            // GUARD: Make sure we get a response status in a successful range
            let successRange: Range<Int> = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Make sure there is data coming back from the api
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the byte objects and convert them to a JSON object
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
        
    }
    
    func taskForCredentialLoginMethod(parameters: [String: AnyObject], completionHandlerForCredentialLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void ) -> Void {

        let placeHolder = [String: AnyObject]()
        
        let username: String = String(describing: parameters[OTMClient.JSONBodyValues.Username]!)
        let password: String = String(describing: parameters[OTMClient.JSONBodyValues.Password]!)
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        let _ = taskForPOSTMethod(OTMClient.Constants.AuthURL, parameters: placeHolder, jsonBody: jsonBody) { (results, error) in
            if let error = error {
                completionHandlerForCredentialLogin(nil, error)
            } else {
                if let results = results {
                    self.parseAndSaveLoginDetails(results as! [String: AnyObject])
                    completionHandlerForCredentialLogin(results, nil)
                } else {
                    completionHandlerForCredentialLogin(nil, NSError(domain: "taskForCredentialLoginMethod parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse taskForCredentialLoginMethod results"]))
                }
            }
        }
    }
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
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
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
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
            
            /* Trim the first 5 bytes if we are posting to udacity */
            var newData: Data = data!
            if method == OTMClient.Constants.AuthURL {
                newData = self.normalizeAuth(data!)
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func normalizeAuth(_ data: Data) -> Data {
        let range = Range(5..<data.count)
        return data.subdata(in: range)
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
    
    private func otmRequestWithApiKeys(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: OTMClient.Constants.ParseApiKeyHeader)
        request.addValue(OTMClient.Constants.RESTApiKey, forHTTPHeaderField: OTMClient.Constants.RESTApiKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func otmParseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = OTMClient.Constants.ApiHost
        components.path = OTMClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func combine(_ baseParams: [String: AnyObject], with options: [String: AnyObject]) -> [String: AnyObject] {
        var paramsWithOptions = baseParams
        for (key, value) in options {
            paramsWithOptions.updateValue(value, forKey: key)
        }
        return paramsWithOptions
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
