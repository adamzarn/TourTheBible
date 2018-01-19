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
    
    static let shared = GlobalFunctions()
    private override init() {
        super.init()
    }
    
}
