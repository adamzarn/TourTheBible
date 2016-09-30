//
//  Pin+CoreDataProperties.swift
//  
//
//  Created by Adam Zarn on 9/30/16.
//
//

import Foundation
import CoreData

extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var title: String?
    @NSManaged public var image: NSData?
    @NSManaged public var pinToBook: Book?

}
