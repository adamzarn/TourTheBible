//
//  GlossaryLaunchController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/19/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class GlossaryLaunchController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        let containerViewController = GlossaryContainerViewController()
        self.present(containerViewController, animated: false)
    }
    
}
