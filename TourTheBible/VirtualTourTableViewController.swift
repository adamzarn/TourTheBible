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
    
    let defaults = UserDefaults.standard
    var tourNames: [String] = []
    var passwords: [String] = []
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        aiv.startAnimating()
        aiv.isHidden = false
        myTableView.isHidden = true
        if FirebaseClient.sharedInstance.hasConnectivity() {
            tourNames = []
            passwords = []
            FirebaseClient.sharedInstance.getTourNames(completion: { (tourNames, error) -> () in
                if let tourNames = tourNames {
                    self.tourNames = tourNames.allKeys as! [String]
                    self.tourNames.sort()
                    for tourName in self.tourNames {
                        self.passwords.append(tourNames[tourName] as! String)
                    }
                    self.myTableView.reloadData()
                    self.myTableView.isHidden = false
                    self.aiv.isHidden = true
                    self.aiv.stopAnimating()
                }
            })
        } else {
            tourNames = ["No Internet Connection"]
            passwords = [""]
            myTableView.reloadData()
            myTableView.isHidden = false
            aiv.isHidden = true
            aiv.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = tourNames[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tourNames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tourNames[0] != "No Internet Connection" {
            
            if defaults.bool(forKey: tourNames[indexPath.row]) {
                
                let vc = VirtualTourContainerViewController()
                vc.tour = self.tourNames[indexPath.row]
                self.present(vc, animated: true, completion: nil)
                
            } else {
                
                let alertController = UIAlertController(title: tourNames[indexPath.row], message: "Please enter this tour's password:", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                
                alertController.addTextField { (textField) in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                }
                
                let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
                    if let submission = alertController.textFields![0] as? UITextField {
                        if submission.text == self.passwords[indexPath.row] {
                            let vc = VirtualTourContainerViewController()
                            vc.tour = self.tourNames[indexPath.row]
                            self.present(vc, animated: true, completion: nil)
                            self.defaults.setValue(true, forKey: self.tourNames[indexPath.row])
                        } else {
                            self.presentTryAgain(correctPassword: self.passwords[indexPath.row], tour: self.tourNames[indexPath.row])
                        }
                    }
                }
                alertController.addAction(submitAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func presentTryAgain(correctPassword: String, tour: String) {
        let alertController = UIAlertController(title: tour, message: "Incorrect Password. Please try again:", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            if let submission = alertController.textFields![0] as? UITextField {
                if submission.text == correctPassword {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VirtualTourViewController") as! VirtualTourViewController
                    vc.tour = tour
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.presentTryAgain(correctPassword: correctPassword, tour: tour)
                }
            }
        }
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
