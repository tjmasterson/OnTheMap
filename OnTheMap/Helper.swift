//
//  Helper.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 9/14/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//


import UIKit

class Helper: NSObject  {
    

    class func orientationIsLandscape() -> Bool {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return true
        default:
            return false
        }
    }
    
    class func handleError(_ errorString: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "", message: errorString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
