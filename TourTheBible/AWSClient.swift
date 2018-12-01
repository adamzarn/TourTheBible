//
//  AWSClient.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/18/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

class AWSClient: NSObject {
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    let dynamoDB = AWSDynamoDB.default()
    
    func getChapterAppearances(location: String, completion: @escaping (_ chapterAppearances: [[Chapter]]?, _ error: NSString?) -> ()) {

        let queryExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(AWSChapterLocations.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            var chapterAppearances: [[Chapter]] = []
            if let results = task.result {
                
                var chaptersArray: [String] = []
                
                for item in results.items as! [AWSChapterLocations] {
                    let locs = item.getLocationComponent(csvIndex: .properName)
                    if locs.contains(location) {
                        chaptersArray.append(item.chapter!)
                    }
                }
        
                var chapters: [Chapter] = []
                for chapter in chaptersArray {
                    var chapterComponents = chapter.split{$0 == " "}.map(String.init)
                    let chapterNumber = Int(chapterComponents.removeLast())!
                    let book = chapterComponents.joined(separator: " ")
                    chapters.append(Chapter(book: book, chapterNumber: chapterNumber))
                }
        
                var tempArray: [Chapter] = []
                for book in Books.books {
                    tempArray = []
                    for chapter in chapters {
                        if chapter.book == book {
                            tempArray.append(chapter)
                        }
                    }
                    if tempArray.count > 0 {
                        tempArray.sort { $0.chapterNumber < $1.chapterNumber }
                        chapterAppearances.append(tempArray)
                    }
                }
                
                completion(chapterAppearances, nil)

            } else {
                completion(nil, "Could not retrieve chapter appearances")
            }
            
            return nil
        })
    }
    
    func getBibleLocations(completion: @escaping (_ bibleLocations: [BibleLocation]?, _ error: NSString?) -> ()) {
    
        let queryExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(AWSBibleLocation.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if let results = task.result {
                var bibleLocations: [BibleLocation] = []
                for item in results.items as! [AWSBibleLocation] {
                    let loc = BibleLocation(name: item.name!, lat: item.lat!, long: item.long!)
                    bibleLocations.append(loc)
                }
                completion(bibleLocations, nil)
            } else {
                completion(nil, "Could not retrieve Bible Locations")
            }
            return nil
        })
        
    }
    
    func getBibleLocation(name: String, completion: @escaping (_ bibleLocation: BibleLocation?, _ error: NSString?) -> ()) {

        dynamoDBObjectMapper.load(AWSBibleLocation.self, hashKey: name, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if let result = task.result as? AWSBibleLocation {
                let bibleLocation = BibleLocation(name: result.name!, lat: result.lat!, long: result.long!)
                completion(bibleLocation, nil)
            } else {
                completion(nil, "Could not retrieve Bible Location")
            }
            return nil
        })
    }
    
    func getChapterLocations(chapter: String, completion: @escaping (_ chapterLocations: [String]?, _ error: NSString?) -> ()) {

        dynamoDBObjectMapper.load(AWSChapterLocations.self, hashKey: chapter, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if let result = task.result as? AWSChapterLocations {
                let chapterLocations = result.locations
                completion(chapterLocations, nil)
            } else {
                completion(nil, "Could not retrieve Chapter Locations")
            }
            return nil
        })
    }
    
    func getTours(search: String, completion: @escaping (_ tours: [AWSTour]?, _ error: NSString?) -> ()) {
        let queryExpression = AWSDynamoDBScanExpression()
        queryExpression.filterExpression = "begins_with(lowercasedOrganization, :search)"
        queryExpression.expressionAttributeValues = [":search": search]
        dynamoDBObjectMapper.scan(AWSTour.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let results = task.result {
                completion(results.items as? [AWSTour], nil)
            } else {
                completion(nil, "Could not retrieve Chapter Locations")
            }
            return nil
        })
    }
    
    func getMyTourKeys(email: String, completion: @escaping (_ tourKeys: [String]?, _ error: NSString?) -> ()) {
        
        dynamoDBObjectMapper.load(AWSUser.self, hashKey: email, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let result = task.result as? AWSUser {
                let tourKeys = result.tours
                completion(tourKeys, nil)
            } else {
                completion(nil, "Could not retrieve Tour Keys")
            }
            return nil
        })
    }
    
    func getTour(uid: String, completion: @escaping (_ tour: AWSTour?, _ error: NSString?) -> ()) {
        
        dynamoDBObjectMapper.load(AWSTour.self, hashKey: uid, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let result = task.result as? AWSTour {
                completion(result, nil)
            } else {
                completion(nil, "Could not retrieve Tour")
            }
            return nil
        })
        
    }
    
    func updateMyTours(email: String, tourKeys: [String], completion: @escaping (_ success: Bool?, _ error: String?) -> ()) {
        
        let updateItemInput = AWSDynamoDBUpdateItemInput()
        
        updateItemInput?.tableName = "TourTheBibleUsers"
        
        let keyVal = AWSDynamoDBAttributeValue()
        keyVal?.s = email
        updateItemInput?.key = ["email": keyVal!]
        
        updateItemInput?.updateExpression = "set tours = :t"
        
        var tourKeysValues: [AWSDynamoDBAttributeValue] = []
        for key in tourKeys {
            let newTourKeysValue = AWSDynamoDBAttributeValue()
            newTourKeysValue?.s = key
            tourKeysValues.append(newTourKeysValue!)
        }
        let tourKeysValue = AWSDynamoDBAttributeValue()
        tourKeysValue?.l = tourKeysValues
        
        updateItemInput?.expressionAttributeValues = [
            ":t": tourKeysValue!
        ]
        
        dynamoDB.updateItem(updateItemInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                completion(true, nil)
            } else {
                completion(false, task.error?.localizedDescription)
            }
            return nil
        })
        
    }
    
    func addUser(email: String, name: String, completion: @escaping (_ success: Bool?, _ error: String?) -> ()) {
        
        let putItemInput = AWSDynamoDBPutItemInput()
        
        putItemInput?.tableName = "TourTheBibleUsers"
        
        let emailValue = AWSDynamoDBAttributeValue()
        emailValue?.s = email
        
        let nameValue = AWSDynamoDBAttributeValue()
        nameValue?.s = name
        
        putItemInput?.item = [
            "email" : emailValue!,
            "name": nameValue!
        ]
        
        dynamoDB.putItem(putItemInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(true, nil)
            }
            return nil
        })
        
    }
    
    func userExists(email: String, completion: @escaping (_ exists: Bool?, _ error: String?) -> ()) {
        dynamoDBObjectMapper.load(AWSUser.self, hashKey: email, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                completion(nil, error.localizedDescription)
            } else {
                if task.result != nil {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            }
            return nil
        })
        
    }
    
    static let sharedInstance = AWSClient()
    private override init() {
        super.init()
    }
}
