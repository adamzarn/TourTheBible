//
//  Book+CoreDataClass.swift
//  
//
//  Created by Adam Zarn on 9/30/16.
//
//

import Foundation
import CoreData

public class Book: NSManagedObject {

    convenience init(name: String, context : NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
}
