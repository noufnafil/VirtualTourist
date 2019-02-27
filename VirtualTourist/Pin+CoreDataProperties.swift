//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var hasPhotos: NSSet?
    
}

// MARK: Generated accessors for hasPhotos
extension Pin {
    
    @objc(addHasPhotosObject:)
    @NSManaged public func addToHasPhotos(_ value: Photo)
    
    @objc(removeHasPhotosObject:)
    @NSManaged public func removeFromHasPhotos(_ value: Photo)
    
    @objc(addHasPhotos:)
    @NSManaged public func addToHasPhotos(_ values: NSSet)
    
    @objc(removeHasPhotos:)
    @NSManaged public func removeFromHasPhotos(_ values: NSSet)
    
}
