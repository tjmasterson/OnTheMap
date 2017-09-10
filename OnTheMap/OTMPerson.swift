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
        createdAt = dictionary[ParseClient.JSONResponseKeys.PersonCreatedAt] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.PersonFirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.PersonLastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.PersonLatitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.PersonLongitude] as! Double
        mapString = dictionary[ParseClient.JSONResponseKeys.PersonMapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.PersonMediaURL] as! String
        objectID = dictionary[ParseClient.JSONResponseKeys.PersonObjectID] as! String
        updatedAt = dictionary[ParseClient.JSONResponseKeys.PersonUpdatedAt] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.PersonUniqueKey] as? String
    }
    
    static func peopleFromResults(_ results: [[String:AnyObject]]) -> [OTMPerson] {
        var collectionOfPeople = [OTMPerson]()
        for person in results {
            if self.allValuesPresent(person) {
                collectionOfPeople.append(OTMPerson(dictionary: person))
            }
        }
        return collectionOfPeople
    }
    
    static func allValuesPresent(_ person: [String: AnyObject?]) -> Bool {
        for (_, value) in person {
            if let _ = value {
                return false
            }
        }
        return true
    }
    
}
