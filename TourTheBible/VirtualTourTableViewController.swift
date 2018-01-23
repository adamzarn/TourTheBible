//
//  VirtualTourTableViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/7/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class VirtualTourTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate {
    
    let defaults = UserDefaults.standard
    var tours: [AWSTour] = []
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    var tableViewShrunk = false
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var userDetails: AWSCognitoIdentityUserGetDetailsResponse?
    var email: String?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var tourKeys: [String] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)

        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = GlobalFunctions.shared.themeColor()
        searchController.searchBar.placeholder = "Search by Tour Organization..."
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.doneLoadingTableView()


    }

    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        print("subscribed")
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        if (self.user == nil) {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
        } else {
            if segmentedControl.selectedSegmentIndex == 0 {
                loadingTableView()
                getUserDetails()
            } else {
                tours = []
                myTableView.reloadData()
                doneLoadingTableView()
            }
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        tourKeys = []
        tours = []
        if segmentedControl.selectedSegmentIndex == 0 {
            dismissSearchController()
            myTableView.tableHeaderView = nil
            loadingTableView()
            if let email = email {
                getMyTourKeys(email: email)
            }
        } else {
            myTableView.reloadData()
            myTableView.tableHeaderView = searchController.searchBar
            if let email = email {
                getMyTourKeys(email: email)
            }
        }
    }
    
    func dismissSearchController() {
        searchController.searchBar.text = ""
        searchController.isActive = false
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func getMyTourKeys(email: String) {
        tours = []
        AWSClient.sharedInstance.getMyTourKeys(email: email, completion: { (tourKeys, error) -> () in
            if let tourKeys = tourKeys {
                self.tourKeys = tourKeys
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.getTours()
                }
            } else {
                self.myTableView.reloadData()
                self.doneLoadingTableView()
            }
        })
    }
    
    func getTours() {
        tours = []
        var toursFetched = 0
        if tourKeys.count > 0 {
            for uid in tourKeys {
                AWSClient.sharedInstance.getTour(uid: uid, completion: { (tour, error) -> () in
                    toursFetched += 1
                    if let tour = tour {
                        self.tours.append(tour)
                    } else {
                        print(error!)
                    }
                    if toursFetched == self.tourKeys.count {
                        self.myTableView.reloadData()
                        self.doneLoadingTableView()
                    }
                })
            }
        } else {
            doneLoadingTableView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        print("unsubscribed")
    }
    
    func loadingTableView() {
        tours = []
        aiv.isHidden = false
        aiv.startAnimating()
        myTableView.isHidden = true
    }
    
    func doneLoadingTableView() {
        aiv.isHidden = true
        aiv.stopAnimating()
        myTableView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("reloading for some reason")
        let cell = tableView.dequeueReusableCell(withIdentifier: "tourCell") as! TourCell
        cell.setUpTourCell(tour: tours[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let userDetails = userDetails {
            if segmentedControl.selectedSegmentIndex == 0 {
                return (userDetails.userAttributes?[2].value)! + " " + (userDetails.userAttributes?[3].value)! + "'s Tours"
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if segmentedControl.selectedSegmentIndex == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let tourUidToRemove = tours[indexPath.row].uid
        
        if editingStyle == .delete {
            let updatedTourKeys = tourKeys.filter { $0 != tourUidToRemove }
            if let email = email {
                AWSClient.sharedInstance.updateMyTours(email: email, tourKeys: updatedTourKeys, completion: { (success, error) -> () in
                    if let success = success {
                        if success {
                            self.tourKeys = updatedTourKeys
                            self.tours.remove(at: indexPath.row)
                            self.myTableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    } else {
                        self.displayAlert(title: "Error", message: error!)
                    }
                })
            } else {
                displayAlert(title: "Error", message: "No user is logged in.")
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tour = tours[indexPath.row]

        if segmentedControl.selectedSegmentIndex == 1 {
            
            if tourKeys.contains(tour.uid) {
                presentTour(tour: tour)
            }
                
            let alertController = UIAlertController(title: tour.name, message: "Please enter this tour's password:", preferredStyle: .alert)
                
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
                
            alertController.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
                
            let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
                let submission = alertController.textFields![0]
                if submission.text == tour.password {
                    var updatedTourKeys = self.tourKeys
                    updatedTourKeys.append(tour.uid)
                    AWSClient.sharedInstance.updateMyTours(email: self.email!, tourKeys: updatedTourKeys, completion: { (success, error) -> () in
                        if let error = error {
                            self.displayAlert(title: "Error", message: error)
                        } else {
                            self.presentTour(tour: tour)
                        }
                    })
                } else {
                    self.presentTryAgain(tour: self.tours[indexPath.row])
                }
            }
            alertController.addAction(submitAction)
                
            self.present(alertController, animated: true, completion: nil)
                
        } else {
            
            presentTour(tour: tour)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func presentTour(tour: AWSTour) {
        let vc = VirtualTourContainerViewController()
        vc.tour = tour
        self.dismissSearchController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func presentTryAgain(tour: AWSTour) {
        let alertController = UIAlertController(title: tour.name, message: "Incorrect Password. Please try again:", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            let submission = alertController.textFields![0]
            if submission.text == tour.password {
                self.presentTour(tour: tour)
            } else {
                self.presentTryAgain(tour: tour)
            }
        }
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if segmentedControl.selectedSegmentIndex == 1 {
            if searchText.count > 0 {
                loadingTableView()
                AWSClient.sharedInstance.getTours(search: searchText.lowercased(), completion: { (tours, error) -> () in
                    if let tours = tours {
                        self.tours = tours
                        self.myTableView.reloadData()
                        self.doneLoadingTableView()
                    } else {
                        self.doneLoadingTableView()
                    }
                })
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(VirtualTourTableViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VirtualTourTableViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (!tableViewShrunk) {
            myTableView.frame.size.height -= (getKeyboardHeight(notification: notification) - searchController.searchBar.frame.size.height)
        }
        tableViewShrunk = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (tableViewShrunk) {
            myTableView.frame.size.height += (getKeyboardHeight(notification: notification) - searchController.searchBar.frame.size.height)
        }
        tableViewShrunk = false
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func getUserDetails() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.userDetails = task.result
                for attribute in (self.userDetails?.userAttributes)! {
                    if attribute.name == "email" {
                        self.email = attribute.value
                        self.getMyTourKeys(email: self.email!)
                    }
                }
            })
            return nil
        }
    }
    
}

extension VirtualTourTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension UISearchController {
    open override func viewWillDisappear(_ animated: Bool) {
        searchBar.text = ""
        isActive = false
    }
}
