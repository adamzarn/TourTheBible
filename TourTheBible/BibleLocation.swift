//
//  BibleLocation.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/17/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation

class BibleLocation {
    
    var name: String
    var displayName: String
    var lat: Double
    var long: Double
    
    init(name: String, displayName: String, lat: String, long: String) {
        self.name = name
        self.displayName = displayName
        self.lat = Double(lat)!
        self.long = Double(long)!
    }
    
    init(name: String, displayName: String, lat: Double, long: Double) {
        self.name = name
        self.displayName = displayName
        self.lat = lat
        self.long = long
    }
    
}
