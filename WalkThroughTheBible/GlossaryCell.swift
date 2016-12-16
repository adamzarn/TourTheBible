//
//  GlossaryCell.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 10/10/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class GlossaryCell: UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myDetailLabel: UILabel!
    
    func setUp(location: BibleLocation) {
        self.myImageView.image = UIImage(named: "Pin")
        self.myLabel!.text = location.name
        if location.key?.caseInsensitiveCompare(location.name!) != ComparisonResult.orderedSame {
            self.myDetailLabel!.text = location.key
        } else {
            self.myDetailLabel!.text = ""
        }
        
    }
    
}
