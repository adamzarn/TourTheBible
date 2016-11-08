//
//  CustomBookCell.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/29/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class CustomBookCell: UITableViewCell {
    
    @IBOutlet weak var book: UILabel!
    
    func setUp() {
        self.backgroundColor = UIColor.clear
        //book.font = UIFont(name: "Papyrus", size: 35.0)
        book.font = UIFont.systemFont(ofSize: 24.0)
        
    }
    
}
