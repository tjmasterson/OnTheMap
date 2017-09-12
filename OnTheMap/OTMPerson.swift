//
//  OTMPerson.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

struct OTMPerson {
    
    let createdAt: String?
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String?
    let mediaURL: String
    let objectID: String
    let updatedAt: String?
    let uniqueKey: String?
    
    init?(dictionary: [String: AnyObject]) throws {
        guard let createdAt = dictionary[ParseClient.JSONResponseKeys.PersonCreatedAt] as? String else {
            throw OTMPersonError.missingAncillaryAttribute(attribute: ParseClient.JSONResponseKeys.PersonCreatedAt)
        }
        guard let firstName = dictionary[ParseClient.JSONResponseKeys.PersonFirstName] as? String else {
            throw OTMPersonError.missingCriticalAttribute(attribute: ParseClient.JSONResponseKeys.PersonFirstName)
        }
        guard let lastName = dictionary[ParseClient.JSONResponseKeys.PersonLastName] as? String else {
            throw OTMPersonError.missingCriticalAttribute(attribute: ParseClient.JSONResponseKeys.PersonLastName)
        }
        guard let latitude = dictionary[ParseClient.JSONResponseKeys.PersonLatitude] as? Double else {
            throw OTMPersonError.missingCriticalAttribute(attribute: ParseClient.JSONResponseKeys.PersonLatitude)
        }
        guard let longitude = dictionary[ParseClient.JSONResponseKeys.PersonLongitude] as? Double else {
            throw OTMPersonError.missingCriticalAttribute(attribute: ParseClient.JSONResponseKeys.PersonLongitude)
        }
        guard let mapString = dictionary[ParseClient.JSONResponseKeys.PersonMapString] as? String else {
            throw OTMPersonError.missingAncillaryAttribute(attribute: ParseClient.JSONResponseKeys.PersonMapString)
        }
        guard let mediaURL = dictionary[ParseClient.JSONResponseKeys.PersonMediaURL] as? String else {
            throw OTMPersonError.missingCriticalAttribute(attribute: ParseClient.JSONResponseKeys.PersonMediaURL)
        }
        guard let objectID = dictionary[ParseClient.JSONResponseKeys.PersonObjectID] as? String else {
            throw OTMPersonError.missingAncillaryAttribute(attribute: ParseClient.JSONResponseKeys.PersonObjectID)
        }
        guard let updatedAt = dictionary[ParseClient.JSONResponseKeys.PersonUpdatedAt] as? String else {
            throw OTMPersonError.missingAncillaryAttribute(attribute: ParseClient.JSONResponseKeys.PersonUpdatedAt)
        }
        guard let uniqueKey = dictionary[ParseClient.JSONResponseKeys.PersonUniqueKey] as? String else {
            throw OTMPersonError.missingAncillaryAttribute(attribute: ParseClient.JSONResponseKeys.PersonUniqueKey)
        }
        
        self.createdAt = createdAt 
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectID = objectID
        self.updatedAt = updatedAt
        self.uniqueKey = uniqueKey
 
    }
    
    static func peopleFromResults(_ results: [[String:AnyObject]]) -> [OTMPerson] {
        var collectionOfPeople = [OTMPerson]()
        for person in results {
            do {
                let otmPerson = try OTMPerson(dictionary: person)!
                collectionOfPeople.append(otmPerson)
            } catch let error {
                handleError(error as! OTMPersonError)
            }
        }
        return collectionOfPeople
    }
    
    
    static func handleError(_ error: OTMPersonError) {
        let prefix = "Init of OTMPerson Failed."
        switch error {
        case .missingCriticalAttribute(let attribute):
            print("\(prefix) Missing Critical Attribute: \(attribute) \n")
        case .missingAncillaryAttribute(let attribute):
            print("\(prefix) Missing Ancillary Attribute: \(attribute) \n")
        }
    }
    
}

enum OTMPersonError: Error {
    case missingCriticalAttribute(attribute: String)
    case missingAncillaryAttribute(attribute: String)
    
}
