//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/10/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        static let ParseApiKeyHeader = "X-Parse-Application-Id"
        static let RESTApiKeyHeader = "X-Parse-REST-API-Key"
        
        static let ParseApiKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct Methods {
        static let Auth = "/session"
        static let User = "/users/{uniqueKey}"
    }
    
    struct ParameterKeys {
        static let AuthWrapper = "udacity"
    }
    
    struct JSONBodyKeys {
        static let AuthWrapper = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let UserID = "key"
        static let Session = "session"
        static let SessionID = "id"
        static let Expiration = "expiration"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
    
    struct UserKeys {
        static let UserID = "uniqueKey"
        static let UserSessionID = "sessionID"
        static let UserFirstName = "firstName"
        static let UserLastName = "lastName"
    }
}
