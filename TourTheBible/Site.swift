//
//  Site.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/21/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation

class Site {
    
    var date: String!
    var lat: Double!
    var long: Double!
    var name: String!
    var notes: String!
    var stop: Int!

    init(date: String, lat: Double, long: Double, name: String, notes: String, stop: Int) {
        self.date = date
        self.lat = lat
        self.long = long
        self.name = name
        self.notes = notes
        self.stop = stop
    }
    
    init(date: String, lat: String, long: String, name: String, notes: String, stop: String) {
        self.date = date
        self.lat = Double(lat)!
        self.long = Double(long)!
        self.name = name
        self.notes = notes
        self.stop = Int(stop)!
    }
    
    
}
