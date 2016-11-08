//
//  BiblesViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 11/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class BiblesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myTableView: UITableView!
    
    let bibles = ["King James Version", "English Standard Version (coming soon)"]
    let activated = [true, false]
    var selectedBible: String? = nil
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bibles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = bibles[indexPath.row]
        
        if !activated[indexPath.row] {
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.isUserInteractionEnabled = false
        }
        
        if bibles[indexPath.row] == selectedBible {
            cell?.accessoryType = .checkmark
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}
