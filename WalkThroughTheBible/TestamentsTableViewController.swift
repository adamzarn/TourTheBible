//
//  TestamentsTableViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 10/3/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class TestamentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let testaments = ["Old Testament", "New Testament"]
    
    var hasBeenShown = [Bool](repeating: false, count: 2)
    
    override func viewDidLoad() {
        
        let imageView = UIImageView(image: UIImage(named: "Papyrus"))
        myTableView.backgroundView = imageView
        myTableView.backgroundView?.alpha = 0.4
        
        let screenSize: CGRect = UIScreen.main.bounds
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = screenSize.height - y - (tabBarController?.tabBar.frame.size.height)!
        
        myTableView.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: height)
        
        myTableView.isScrollEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !hasBeenShown[indexPath.row] {
            
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
            
        }
        
        hasBeenShown[indexPath.row] = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = screenSize.height - y - (tabBarController?.tabBar.frame.size.height)!
        return height/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomBookCell
        
        cell.book.text = testaments[indexPath.row]
       
        cell.setUp()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testaments.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let vc = storyboard?.instantiateViewController(withIdentifier: "BooksTableViewController") as! BooksTableViewController
            vc.testamentIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
            
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

