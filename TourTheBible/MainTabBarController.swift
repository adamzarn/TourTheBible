//
//  MainTabBarController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/13/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar = self.tabBar
        tabBar.isTranslucent = false
        appDelegate.tabBarHeight = tabBar.frame.size.height
        let bookItem = tabBar.items?[0]
        let glossaryItem = tabBar.items?[1]
        let tourItem = tabBar.items?[2]
        let biblesItem = tabBar.items?[3]
        let aboutItem = tabBar.items?[4]
        
        glossaryItem?.title = "Glossary"
        
        bookItem?.image = resizeImage(image: UIImage(named:"Book")!)
        glossaryItem?.image = resizeImage(image: UIImage(named:"List")!)
        tourItem?.image = resizeImage(image: UIImage(named:"Tourist")!)
        biblesItem?.image = resizeImage(image: UIImage(named:"Bibles")!)
        aboutItem?.image = resizeImage(image: UIImage(named:"About")!)
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let newWidth = image.size.width/1.75
        let newHeight = image.size.height/1.75
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}
