//
//  ParseConvenienceMethods.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/10/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func taskForGETMethod(_ method: String, parameters: [String: AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = parseURLFromParameters(parameters, withPathExtension: method)
        let request = parseRequestWithApiKeys(url: url, httpMethod: "GET")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Make sure we don't get an error from the server
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
            
            // GUARD: Make sure there is data coming back from the server
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
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject] = [String:AnyObject](), jsonBodyData: [String: AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = parseURLFromParameters(parameters, withPathExtension: method)
        let request = parseRequestWithApiKeys(url: url, httpMethod: "POST")
        request.httpBody = serializeJSONBodyData(jsonBodyData)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Make sure we don't get an error from the server
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            // GUARD: Make sure we get a response status in a successful range
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Make sure there is data coming back from the server
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(_ method: String, parameters: [String:AnyObject] = [String:AnyObject](), jsonBodyData: [String: AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = parseURLFromParameters(parameters, withPathExtension: method)
        let request = parseRequestWithApiKeys(url: url, httpMethod: "PUT")
        request.httpBody = serializeJSONBodyData(jsonBodyData)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Make sure we don't get an error from the server
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            // GUARD: Make sure we get a response status in a successful range
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Make sure there is data coming back from the server
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        
        return task
    }
    
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }

    private func parseRequestWithApiKeys(url: URL, httpMethod: String) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(ParseClient.Constants.ParseApiKey, forHTTPHeaderField: ParseClient.Constants.ParseApiKeyHeader)
        request.addValue(ParseClient.Constants.RESTApiKey, forHTTPHeaderField: ParseClient.Constants.RESTApiKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        return request
    }
    
    private func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
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
    
    // Given raw JSON, return a usable Foundation object
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
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}
