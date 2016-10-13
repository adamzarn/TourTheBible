//
//  BibleLocation.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/26/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import MapKit

class BibleLocation {
    
    var name: String?
    var lat: Double?
    var long: Double?
    
    init(name: String, lat: Double, long: Double) {
        self.name = name
        self.lat = lat
        self.long = long
        
    }
    
}
