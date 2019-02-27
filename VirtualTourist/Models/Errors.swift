//
//  Errors.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation

class Errors {
    
    static func createError(error: String, domain: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
}
