//
//  AWSClient.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/17/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSBibleLocation: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {

    var name: String?
    var displayName: String?
    var lat: String?
    var long: String?
        
    class func dynamoDBTableName() -> String {
        return "BibleLocations"
    }

    class func hashKeyAttribute() -> String {
        return "name"
    }
    
}

class AWSChapterLocations: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var chapter: String?
    var locations: [String]?
    
    class func dynamoDBTableName() -> String {
        let defaults = UserDefaults.standard
        let bible = defaults.value(forKey: "selectedBible") as! String
        let tableName = bible.replacingOccurrences(of: " ", with: "")
        return tableName
    }
    
    class func hashKeyAttribute() -> String {
        return "chapter"
    }
    
}
