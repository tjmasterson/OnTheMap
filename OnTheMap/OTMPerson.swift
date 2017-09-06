//
//  OTMPerson.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

struct OTMPerson {
    
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectID: String
    let updatedAt: String
    let uniqueKey: String?
    
    init(dictionary: [String: AnyObject]) {
        createdAt = dictionary[OTMClient.JSONResponseKeys.PersonCreatedAt] as! String
        firstName = dictionary[OTMClient.JSONResponseKeys.PersonFirstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.PersonLastName] as! String
        latitude = dictionary[OTMClient.JSONResponseKeys.PersonLatitude] as! Double
        longitude = dictionary[OTMClient.JSONResponseKeys.PersonLongitude] as! Double
        mapString = dictionary[OTMClient.JSONResponseKeys.PersonMapString] as! String
        mediaURL = dictionary[OTMClient.JSONResponseKeys.PersonMediaURL] as! String
        objectID = dictionary[OTMClient.JSONResponseKeys.PersonObjectID] as! String
        updatedAt = dictionary[OTMClient.JSONResponseKeys.PersonUpdatedAt] as! String
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.PersonUniqueKey] as? String
    }
    
    static func peopleFromResults(_ results: [[String:AnyObject]]) -> [OTMPerson] {
        var people = [OTMPerson]()
        
        for person in results {
            people.append(OTMPerson(dictionary: person))
        }
        
        return people
    }
}
