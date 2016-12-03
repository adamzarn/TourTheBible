//
//  BibleLocation+CoreDataClass.swift
//  
//
//  Created by Adam Zarn on 12/3/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

public class BibleLocation: NSManagedObject {
    
    convenience init(lat: Double, long: Double, key: String, name: NSData, context : NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "BibleLocation", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.long = long
            self.key = key
            self.name = name
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    
}
