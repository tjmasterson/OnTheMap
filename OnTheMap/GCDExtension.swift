//
//  GCDExtension.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
