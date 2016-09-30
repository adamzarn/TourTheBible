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
    @IBOutlet weak var detail: UITextView!
    
    func setUp() {
        self.backgroundColor = UIColor.clear
        book.font = UIFont(name: "Papyrus", size: 35.0)
        detail.font = UIFont(name:"Helvetica-Light", size:16.0)
        detail.isEditable = false
        detail.isScrollEnabled = false
        detail.backgroundColor = UIColor.clear
        detail.isUserInteractionEnabled = false
    }
    
}
