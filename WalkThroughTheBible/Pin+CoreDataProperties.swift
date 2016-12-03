//
//  Pin+CoreDataProperties.swift
//  
//
//  Created by Adam Zarn on 12/3/16.
//
//  This file was automatically generated and should not be edited.
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
