//
//  UdacityConvenienceMethods.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/10/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func taskForGETMethod(_ method: String, parameters: [String: AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = udacityURLFromParameters(parameters, withPathExtension: method)
        let request = udacityRequestWithHeaders(url: url, httpMethod: "GET")
        
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
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange ~= statusCode else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Make sure there is data coming back from the server
            guard let data = data else {
                sendError("No data returned by the request!")
                return
            }
            
            /* Trim the first 5 bytes if we are posting to udacity */
            let newData: Data = self.normalizeUdacityResponse(data)
            
            // Parse the byte objects and convert them to a JSON object
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
        
    }

    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject] = [String:AnyObject](), jsonBodyData: [String: AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = udacityURLFromParameters(parameters, withPathExtension: method)
        let request = udacityRequestWithHeaders(url: url, httpMethod: "POST")
        request.httpBody = serializeJSONBodyData(jsonBodyData)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Make sure we didn't get an error from the server */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Make sure our response status code in in a successful range */
            let successRange: Range<Int> = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange ~= statusCode else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Make sure we have data coming back from the server */
            guard let data = data else {
                sendError("No data returned by the request!")
                return
            }
            
            /* Trim the first 5 bytes if we are posting to udacity */
            let newData: Data = self.normalizeUdacityResponse(data)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func normalizeUdacityResponse(_ data: Data) -> Data {
        let range = Range(5..<data.count)
        return data.subdata(in: range)
    }
    
    func parseAndSaveLoginDetails(_ data: [String:AnyObject], completionHandlerForSaveLoginDetails: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        func sendError(_ error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForSaveLoginDetails(nil, NSError(domain: "parseAndSaveLoginDetails", code: 1, userInfo: userInfo))
        }
        
        guard let account = data[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
            sendError("Could not find data for key \(UdacityClient.JSONResponseKeys.Account) while trying to save login detials")
            return
        }
        
        guard let userID = account[UdacityClient.JSONResponseKeys.UserID] as? String else {
            sendError("Could not find data for key \(UdacityClient.JSONResponseKeys.Account) while trying to save login detials")
            return
        }
        
        guard let session = data[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] else {
            sendError("Could not find data for key \(UdacityClient.JSONResponseKeys.Account) while trying to save login detials")
            return
        }
        
        guard let sessionID = session[UdacityClient.JSONResponseKeys.SessionID] as? String else {
            sendError("Could not find data for key \(UdacityClient.JSONResponseKeys.Account) while trying to save login detials")
            return
        }
        
        var userToSave: [String: AnyObject] = [
            UdacityClient.UserKeys.UserID: userID,
            UdacityClient.UserKeys.UserSessionID: sessionID
        ] as [String: AnyObject]
        
        var mutableMethod: String = UdacityClient.Methods.User
        mutableMethod = substituteKeyInMethod(mutableMethod, key: UdacityClient.UserKeys.UserID, value: userID)!

        let _ = taskForGETMethod(mutableMethod, parameters: userToSave) { (results, error) in
            if let error = error {
                completionHandlerForSaveLoginDetails(nil, error)
            } else {
                if let results = results {
                    guard let user = results[UdacityClient.JSONResponseKeys.User] as? [String: AnyObject] else {
                        print("shit")
                        return
                    }
                    
                    guard let firstName = user[UdacityClient.JSONResponseKeys.FirstName] as AnyObject? else {
                        print("no")
                        return
                    }
                    
                    guard let lastName = user[UdacityClient.JSONResponseKeys.LastName] as AnyObject? else {
                        print("no")
                        return
                    }
                    
                    userToSave[UdacityClient.UserKeys.UserFirstName] = firstName
                    userToSave[UdacityClient.UserKeys.UserLastName] = lastName
                    
                    OTMData.shared.user = OTMUser(dictionary: userToSave)
                    
                    completionHandlerForSaveLoginDetails(results, nil)
                }
            }
        }
    }
    
    private func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    private func serializeJSONBodyData(_ bodyData: [String: AnyObject]) -> Data {
        var jsonBody: Data = Data()
        do {
            // pass dictionary to nsdata object and set it as request body
            jsonBody = try JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        return jsonBody
    }
    
    private func udacityRequestWithHeaders(url: URL, httpMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        return request
    }
    
    private func udacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
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

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

}
