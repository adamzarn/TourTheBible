//
//  BibleLocation.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/26/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import CoreData

public class BibleLocation: NSManagedObject {
    
    convenience init(name: String, key: String, lat: Double, long: Double, context : NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "BibleLocation", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
            self.key = key
            self.lat = lat
            self.long = long
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
}

