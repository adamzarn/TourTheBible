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
    var lat: String?
    var long: String?
        
    class func dynamoDBTableName() -> String {
        return "BibleLocations"
    }

    class func hashKeyAttribute() -> String {
        return "name"
    }
    
}

enum CSVIndex: Int {
    case asItAppears
    case properName
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
    
    func getLocationComponent(csvIndex: CSVIndex) -> [String] {
        if let locations = locations {
            return locations.map { $0.components(separatedBy: ",")[csvIndex.rawValue] }
        } else {
            return []
        }
    }
    
}

class AWSTour: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var uid: String!
    var createdBy: String!
    var createdByEmail: String!
    var dateCreated: String!
    var endDate: String!
    var lowercasedOrganization: String!
    var name: String!
    var notes: String!
    var organization: String!
    var password: String!
    var sites: [AnyObject]!
    var startDate: String!
    var startYear: String!
    
    class func dynamoDBTableName() -> String {
        return "TourTheBibleTours"
    }
    
    class func hashKeyAttribute() -> String {
        return "uid"
    }
    
}

class AWSUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var email: String!
    var corrections: Int!
    var name: String!
    var tours: [String]!
    var mySites: [AnyObject]!
    
    class func dynamoDBTableName() -> String {
        return "TourTheBibleUsers"
    }
    
    class func hashKeyAttribute() -> String {
        return "email"
    }
    
}
