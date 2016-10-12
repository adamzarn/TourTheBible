//
//  GlossaryViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 10/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class GlossaryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var glossary = [[BibleLocation]]()
    var masterGlossary = [BibleLocation]()
    var filteredGlossary = [BibleLocation]()
    let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","Y","Z"]
    let screenSize: CGRect = UIScreen.main.bounds
    var y: CGFloat?
    var height: CGFloat?
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!/2)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2, width: screenSize.width, height: height!/2)
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredGlossary = masterGlossary.filter { location in
            return (location.name?.lowercased().contains(searchText.lowercased()))!
        }
        
        myTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        glossary = []
        for letter in BibleLocations.Glossary {
            let letter = letter as NSDictionary
            var locations = letter.allValues as! [BibleLocation]
            locations = locations.sorted { $0.name! < $1.name! }
            glossary.append(locations)
            for location in locations {
                masterGlossary.append(location)
            }
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        return letters
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return letters.index(of: title)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredGlossary.count
        }
        
        return glossary[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        return glossary.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return letters[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GlossaryCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.setUp(location: filteredGlossary[indexPath.row])
        } else {
            cell.setUp(location: glossary[indexPath.section][indexPath.row])
        }
        
        return cell
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            let location = filteredGlossary[indexPath.row] as BibleLocation
            setUpMap(name: location.name!, lat: location.lat!, long: location.long!, delta: location.delta!)
        } else {
            let location = glossary[indexPath.section][indexPath.row] as BibleLocation
            setUpMap(name: location.name!, lat: location.lat!, long: location.long!, delta: location.delta!)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.dismiss(animated: true, completion: nil)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2, width: screenSize.width, height: height!/2)
        myTableView.tableHeaderView = nil
        myTableView.reloadData()
        myTableView.setContentOffset(CGPoint.zero, animated: false)
        
    }
    
    func setUpMap(name: String, lat: Double, long: Double, delta: Double) {
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)), animated: true)
        
        let allAnnotations = myMapView.annotations
        var shouldAddAnnotation = true
        var alreadyAddedAnnotation: MKAnnotation?
        
        for annotation in allAnnotations {
            if annotation.coordinate.latitude == lat && annotation.coordinate.longitude == long {
                shouldAddAnnotation = false
                alreadyAddedAnnotation = annotation
            }
        }
        
        if shouldAddAnnotation {
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = name
            myMapView.addAnnotation(annotation)
            myMapView.selectAnnotation(annotation, animated: false)
            
        } else {
            
            myMapView.selectAnnotation(alreadyAddedAnnotation!, animated: false)
            
        }
        
    }

    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins", style: .default) { (action) in
            self.myMapView.removeAnnotations(self.myMapView.annotations)

        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        myTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.becomeFirstResponder()
        myTableView.frame = CGRect(x: 0.0, y: UIApplication.shared.statusBarFrame.size.height, width: screenSize.width, height: screenSize.height-keyboardHeight!-UIApplication.shared.statusBarFrame.size.height)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        myTableView.tableHeaderView = nil
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2, width: screenSize.width, height: height!/2)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async(execute: {
            self.searchController.searchBar.becomeFirstResponder()
        })
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardHeight = getKeyboardHeight(notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    
}

extension GlossaryViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

}
