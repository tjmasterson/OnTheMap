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
    
    var people: [OTMPerson] = [OTMPerson]()
    
    var user: OTMUser?
    
    var userHasPostedLocation: Bool = false
    var overwriteExistingLocation: Bool = false
    
    static let shared = OTMData()
    

}
