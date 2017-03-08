//
//  VirtualTourTableViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/7/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class VirtualTourTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tourNames: [String] = []
    var keys: [String] = []
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        aiv.startAnimating()
        aiv.isHidden = false
        myTableView.isHidden = true
        FirebaseClient.sharedInstance.getTourNames(completion: { (tourNames, error) -> () in
            if let tourNames = tourNames {
                var keys = tourNames.allKeys as! [String]
                keys.sort()
                self.keys = keys
                for key in keys {
                    self.tourNames.append(tourNames[key] as! String)
                }
                print(tourNames)
                self.myTableView.reloadData()
                self.myTableView.isHidden = false
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = tourNames[indexPath.row]
        cell.detailTextLabel?.text = keys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tourNames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "VirtualTourViewController") as! VirtualTourViewController
        vc.year = keys[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
