//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class ParseClient: NSObject {

    // MARK: Properties
    
    // shared session
    var session = URLSession.shared

    var defaultGetPeopleParams = [ParseClient.ParameterKeys.Limit: ParseClient.ParameterValues.Limit,
                                  ParseClient.ParameterKeys.Order: ParseClient.ParameterValues.Order] as [String: AnyObject]
    
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
        
        let _ = taskForGETMethod(ParseClient.Methods.People, parameters: parametersWithOptions) { (results, error) in

            if let error = error {
                completionHandlerForGetPeople(nil, error)
            } else {
                if let results = results?[ParseClient.JSONResponseKeys.PeopleResults] as? [[String:AnyObject]] {
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
        
        let baseUserData: [String: AnyObject] = [
            UdacityClient.UserKeys.UserID: OTMData.shared.user!.uniqueKey,
            UdacityClient.UserKeys.UserFirstName: OTMData.shared.user!.firstName,
            UdacityClient.UserKeys.UserLastName: OTMData.shared.user!.lastName,
        ] as [String: AnyObject]
        
        let paramsWithOptions: [String: AnyObject] = combine(baseUserData, with: parameters)
        let _ = taskForPOSTMethod(ParseClient.Methods.People, jsonBodyData: paramsWithOptions) { (results, error) in
            
            if let error = error {
                completionHandlerForCreatePerson(nil, error)
            } else {
                if let objectID = results?[ParseClient.JSONResponseKeys.ObjectID] as! String? {
                    OTMData.shared.userHasPostedLocation = true
                    OTMData.shared.user!.objectID = objectID
                    completionHandlerForCreatePerson(results, nil)
                } else {
                    completionHandlerForCreatePerson(nil, NSError(domain: "createPersonLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse createPersonLocation"]))
                }
            }
        }

        
    }
    
    
    func updatePersonLocation(_ parameters: [String: AnyObject] = [String: AnyObject](),
                              completionHandlerForUpdatePerson: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let baseUserData: [String: AnyObject] = [
            UdacityClient.UserKeys.UserID: OTMData.shared.user!.uniqueKey,
            UdacityClient.UserKeys.UserFirstName: OTMData.shared.user!.firstName,
            UdacityClient.UserKeys.UserLastName: OTMData.shared.user!.lastName,
            ] as [String: AnyObject]
        
        let paramsWithOptions: [String: AnyObject] = combine(baseUserData, with: parameters)
        
        var mutableMethod: String = ParseClient.Methods.UpdatePerson
        mutableMethod = substituteKeyInMethod(mutableMethod, key: UdacityClient.UserKeys.UserObjectID, value: OTMData.shared.user!.objectID!)!
        let _ = taskForPUTMethod(mutableMethod, jsonBodyData: paramsWithOptions) { (results, error) in
            
            if let error = error {
                completionHandlerForUpdatePerson(nil, error)
            } else {
                if let _ = results?[ParseClient.JSONResponseKeys.PersonUpdatedAt] as AnyObject? {
                    OTMData.shared.userHasPostedLocation = true
                    OTMData.shared.overwriteExistingLocation = false
                    completionHandlerForUpdatePerson(results, nil)
                } else {
                    completionHandlerForUpdatePerson(nil, NSError(domain: "updatePersonLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updatePersonLocation"]))
                }
            }
        }

        
    }
    
    private func combine(_ baseParams: [String: AnyObject], with options: [String: AnyObject]) -> [String: AnyObject] {
        var paramsWithOptions = baseParams
        for (key, value) in options {
            paramsWithOptions.updateValue(value, forKey: key)
        }
        return paramsWithOptions
    }

}
