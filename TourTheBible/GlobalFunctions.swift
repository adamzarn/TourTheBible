//
//  GlobalFunctions.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/18/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class GlobalFunctions: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func themeColor() -> UIColor {
        let color = UIColor(red: 28.0/255.0, green: 62.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        return color
    }
    
    func hasConnectivity() -> Bool {
        do {
            let reachability = Reachability()
            let networkStatus: Int = reachability!.currentReachabilityStatus.hashValue
            return (networkStatus != 0)
        }
    }
    
    func formatDate(date: String) -> String {
        let year = getSubstring(str: date, start: 2, end: 4)
        var month = getSubstring(str: date, start: 5, end: 7)
        var day = getSubstring(str: date, start: 8, end: 10)
        if getSubstring(str: month, start: 0, end: 1) == "0" {
            month = getSubstring(str: month, start: 1, end: 2)
        }
        if getSubstring(str: day, start: 0, end: 1) == "0" {
            day = getSubstring(str: day, start: 1, end: 2)
        }
        return month + "/" + day + "/" + year
    }
    
    func getSubstring(str: String, start: Int, end: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: start)
        let end = str.index(str.startIndex, offsetBy: end)
        let range = start..<end
        return str[range]
    }
    
    static let shared = GlobalFunctions()
    private override init() {
        super.init()
    }
    
}
