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
    
    static let shared = OTMData()
    

}
