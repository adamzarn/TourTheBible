//
//  BiblesViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 11/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class BiblesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let bibles = ["King James Version", "World English Bible", "English Standard Version (coming soon)"]
    let activated = [true, true, false]
    var selectedBible: String? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bibles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = bibles[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        
        if !activated[indexPath.row] {
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.isUserInteractionEnabled = false
        }
        
        if bibles[indexPath.row] == selectedBible {
            cell?.accessoryType = .checkmark
            
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(bibles[indexPath.row], forKey: "selectedBible")
        selectedBible = bibles[indexPath.row]
        
        myTableView.reloadData()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}
