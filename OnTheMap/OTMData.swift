//
//  OTMData.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/7/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

class OTMData {
    
    private init() { }
    
    static let shared = OTMData()

    var people: [OTMPerson] = [OTMPerson]()
    
    func peopleFromResults(_ results: [[String:AnyObject]]) -> [OTMPerson] {
        for person in results {
            if allValuesPresent(person) {
                self.people.append(OTMPerson(dictionary: person))
            }
        }
        return people
    }
    
    func allValuesPresent(_ person: [String: AnyObject?]) -> Bool {
        for (_, value) in person {
            if value == nil {
                return false
            }
        }
        return true
    }

}
