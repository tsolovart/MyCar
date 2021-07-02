//
//  Car+CoreDataProperties.swift
//  Car
//
//  Created by Zaoksky on 28.06.2021.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var timeDriven: NSNumber?
    @NSManaged public var lastStarted: NSDate?
    @NSManaged public var imageData: NSData?
    @NSManaged public var tintColor: NSObject?

}
