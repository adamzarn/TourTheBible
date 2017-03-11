//
//  GlossaryCell.swift
//  TourTheBible
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
    
    func setUp(video: Video) {
        self.myImageView.image = UIImage(named: "Notes")
        let vc = video.verses.characters.split{$0 == ":"}.map(String.init)
        if vc[1] == vc[2] {
            self.myLabel!.text = "\(video.book) \(vc[0]):\(vc[1])"
        } else {
            self.myLabel!.text = "\(video.book) \(vc[0]):\(vc[1])-\(vc[2])"
        }
        self.myDetailLabel!.text = ""
    }
    
}
