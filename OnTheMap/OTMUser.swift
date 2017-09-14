//
//  OTMUser.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/10/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

struct OTMUser {
    
    let firstName: String
    let lastName: String
    let uniqueKey: String
    let sessionID: String
    var objectID: String?
    
    init(dictionary: [String: AnyObject]) {
        uniqueKey = dictionary[UdacityClient.UserKeys.UserID] as! String
        sessionID = dictionary[UdacityClient.UserKeys.UserSessionID] as! String
        firstName = dictionary[UdacityClient.UserKeys.UserFirstName] as! String
        lastName = dictionary[UdacityClient.UserKeys.UserLastName] as! String
        objectID = nil
    }

}
