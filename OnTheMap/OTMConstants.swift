//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

extension OTMClient {
    
    struct Constants {
        static let ParseApiKeyHeader = "X-Parse-Application-Id"
        static let RESTApiKeyHeader = "X-Parse-REST-API-Key"
        static let ParseApiKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let AuthURL = "https://www.udacity.com/api/session"
        static let AuthWrapParameterKey = "udacity"
    }
    
    struct Methods {
        static let People = "/StudentLocation"
        
    }
    
    struct URLKeys {
    
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
    }
    
    struct ParameterValues {
        static let Limit = "100"
        static let Order = "-updatedAt"
    }
    
    struct JSONBodyKeys {
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONBodyValues {
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let PeopleResults = "results"
        
        static let PersonCreatedAt = "createdAt"
        static let PersonFirstName = "firstName"
        static let PersonLastName = "lastName"
        static let PersonLatitude = "latitude"
        static let PersonLongitude = "longitude"
        static let PersonMapString = "mapString"
        static let PersonMediaURL = "mediaURL"
        static let PersonObjectID = "objectId"
        static let PersonUniqueKey = "uniqueKey"
        static let PersonUpdatedAt = "updatedAt"
        
        static let Account = "account"
        static let UserID = "key"
        
        static let Session = "session"
        static let SessionID = "id"
    }
}
