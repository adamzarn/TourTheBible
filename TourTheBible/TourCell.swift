//
//  TourCell.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/21/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class TourCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    func setUpTourCell(tour: AWSTour) {
        nameLabel.text = tour.name
        organizationLabel.text = tour.organization
        datesLabel.text = GlobalFunctions.shared.formatDate(date: tour.startDate) + " - " + GlobalFunctions.shared.formatDate(date: tour.endDate)
        datesLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        createdByLabel.text = "Created by: " + tour.createdBy
        if tour.notes != " " {
            notesLabel.text = tour.notes
        } else {
            notesLabel.text = "No Notes"
        }
    }
    
}
