//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var image: NSData?
    @NSManaged public var photoID: String?
    @NSManaged public var relatesTo: Pin?
    
}
