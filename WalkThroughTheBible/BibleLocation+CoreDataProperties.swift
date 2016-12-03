//
//  BibleLocation+CoreDataProperties.swift
//  
//
//  Created by Adam Zarn on 12/3/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BibleLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BibleLocation> {
        return NSFetchRequest<BibleLocation>(entityName: "BibleLocation");
    }

    @NSManaged public var key: String?
    @NSManaged public var name: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double

}
