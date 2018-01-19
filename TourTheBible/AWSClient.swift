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
    
    func getChapterAppearances(location: String, completion: @escaping (_ chapterAppearances: [[Chapter]]?, _ error: NSString?) -> ()) {
    
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(AWSChapterLocations.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            var chapterAppearances: [[Chapter]] = []
            if let results = task.result {
                var chaptersArray: [String] = []
                for item in results.items as! [AWSChapterLocations] {
                    if let locs = item.locations {
                        if locs.contains(location) {
                            chaptersArray.append(item.chapter!)
                        }
                    }
                }
        
                var chapters: [Chapter] = []
                for chapter in chaptersArray {
                    var chapterComponents = chapter.characters.split{$0 == " "}.map(String.init)
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
    
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(AWSBibleLocation.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let results = task.result {
                var bibleLocations: [BibleLocation] = []
                for item in results.items as! [AWSBibleLocation] {
                    let loc = BibleLocation(name: item.name!, displayName: item.displayName!, lat: item.lat!, long: item.long!)
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
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.load(AWSBibleLocation.self, hashKey: name, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let result = task.result as? AWSBibleLocation {
                print(result.name!, result.displayName!, result.lat!, result.long!)
                let bibleLocation = BibleLocation(name: result.name!, displayName: result.displayName!, lat: result.lat!, long: result.long!)
                completion(bibleLocation, nil)
            } else {
                completion(nil, "Could not retrieve Bible Location")
            }
            return nil
        })
    }
    
    func getChapterLocations(chapter: String, completion: @escaping (_ chapterLocations: [String]?, _ error: NSString?) -> ()) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.load(AWSChapterLocations.self, hashKey: chapter, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if let result = task.result as? AWSChapterLocations {
                let chapterLocations = result.locations
                completion(chapterLocations, nil)
            } else {
                completion(nil, "Could not retrieve Chapter Locations")
            }
            return nil
        })
    }
    
    static let sharedInstance = AWSClient()
    private override init() {
        super.init()
    }
}
