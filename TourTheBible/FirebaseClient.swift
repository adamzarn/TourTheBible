//
//  FirebaseClient.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FirebaseClient: NSObject {
    
    let ref = FIRDatabase.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getVideoIDs(book: String, completion: @escaping (_ videos: [Video]?, _ error: NSString?) -> ()) {
        self.ref.child("Songs").child(book).observeSingleEvent(of: .value, with: { snapshot in
            if let songs = snapshot.value {
                var videos: [Video] = []
                if songs is NSNull {
                    completion(videos, nil)
                } else {
                    for (key,value) in songs as! NSDictionary {
                        let verses = key as! String
                        let videoID = value as! String
                        let video = Video(verses: verses, videoID: videoID, sequence: 0)
                        videos.append(video)
                    }
                    completion(videos, nil)
                }
                
            } else {
                completion(nil, "Could not retrieve Data")
            }
        })
    }
    
    func getVideoLibrary(completion: @escaping (_ videoLibrary: [String: [Video]]?, _ error: NSString?) -> ()) {
        self.ref.child("Songs").observeSingleEvent(of: .value, with: { snapshot in
            if let songs = snapshot.value {
                var videoLibrary: [String: [Video]] = [:]
                for (key,value) in songs as! NSDictionary {
                    let bookName = key as! String
                    let videos = value as! NSDictionary
                    var tempVideos: [Video] = []
                    for (key, value) in videos {
                        let verses = key as! String
                        let videoID = value as! String
                        tempVideos.append(Video(verses: verses, videoID: videoID, sequence: 0))
                    }
                    videoLibrary[bookName] = tempVideos
                }
                completion(videoLibrary, nil)
            } else {
                completion(nil, "Could not retrieve Data")
            }
        })
    }
    
    func getTourNames(completion: @escaping (_ tourNames: NSDictionary?, _ error: NSString?) -> ()) {
        self.ref.child("TourNames").observeSingleEvent(of: .value, with: { snapshot in
            if let tourNamesSnapshot = snapshot.value {
                let tourNames = tourNamesSnapshot as! NSDictionary
                completion(tourNames, nil)
            } else {
                completion(nil, "Could not retrieve Data")
            }
        })
    }
    
    func getTour(year: String, completion: @escaping (_ tour: NSDictionary?, _ error: NSString?) -> ()) {
        self.ref.child("Tours").child(year).observeSingleEvent(of: .value, with: { snapshot in
            if let tourSnapshot = snapshot.value {
                let tour = tourSnapshot as! NSDictionary
                completion(tour, nil)
            } else {
                completion(nil, "Could not retrieve Data")
            }
        })
    }
    
    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }
    
}

