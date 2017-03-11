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
    var bookSequence: Int
    var book: String
    
    init(verses: String, videoID: String, sequence: Int, bookSequence: Int, book: String) {
        self.verses = verses
        self.videoID = videoID
        self.sequence = sequence
        self.bookSequence = bookSequence
        self.book = book
    }
}
