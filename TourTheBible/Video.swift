//
//  Video.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation

struct Video {
    let verses: String
    let videoID: String
    var sequence: Int
    
    init(verses: String, videoID: String, sequence: Int) {
        self.verses = verses
        self.videoID = videoID
        self.sequence = sequence
    }
}
