//
//  CustomBookCell.swift
//  TourTheBible
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
        self.book.font = UIFont(name: "Papyrus", size: 24.0)
        self.book.textColor = UIColor.black
        self.book.font = self.book.font.removeItalics()
    }
    
}
