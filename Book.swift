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

    // Insert code here to add functionality to your managed object subclass
    // Insert code here to add functionality to your managed object subclass
    convenience init(name: String, context : NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
}
