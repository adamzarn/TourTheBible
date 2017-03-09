//
//  GlossaryViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 10/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class GlossaryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mapTypeButton: UIButton!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let searchController = UISearchController(searchResultsController: nil)
    var sortedGlossary = [[BibleLocation]](repeating: [], count: 26)
    var masterGlossary = [BibleLocation]()
    var filteredGlossary = [BibleLocation]()
    let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let screenSize: CGRect = UIScreen.main.bounds
    var y: CGFloat?
    var height: CGFloat?
    var keyboardHeight: CGFloat?
    var selectedBible: String? = nil
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    
    override func viewDidLoad() {
        
        context = appDelegate.managedObjectContext
        masterGlossary = appDelegate.glossary
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        appDelegate.myMapView.delegate = self
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!*0.45)
        appDelegate.myMapView.mapType = MKMapType.standard
        myTableView.frame = CGRect(x: 0.0, y: y! + height!*0.45, width: screenSize.width, height: height!*0.55)
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.automaticallyAdjustsScrollViewInsets = false
        
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        
        mapTypeButton.setTitle(" Satellite ", for: .normal)
        mapTypeButton.layer.borderWidth = 1
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.view.bringSubview(toFront: mapTypeButton)
        
        adjustSubviews()
    }
    
    
    @IBAction func mapTypeButtonPressed(_ sender: Any) {
        if appDelegate.myMapView.mapType == MKMapType.standard {
            appDelegate.myMapView.mapType = MKMapType.satellite
            mapTypeButton.setTitle(" Standard ", for: .normal)
        } else {
            appDelegate.myMapView.mapType = MKMapType.standard
            mapTypeButton.setTitle(" Satellite ", for: .normal)
        }
    }

    func adjustSubviews() {
        let y: CGFloat!
        if self.view.bounds.height < UIScreen.main.bounds.height {
            print("Stupid Banner is showing")
            y = UIApplication.shared.statusBarFrame.size.height
        } else {
            y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        }

        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!

        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!*0.45)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!*0.45, width: screenSize.width, height: height!*0.55)
        self.view.bringSubview(toFront: mapTypeButton)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredGlossary = masterGlossary.filter { location in
            return (location.name?.lowercased().contains(searchText.lowercased()))!
        }
        
        myTableView.reloadData()
        myTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !view.subviews.contains(appDelegate.myMapView) {
            view.addSubview(appDelegate.myMapView)
        }
        if appDelegate.myMapView.mapType == MKMapType.standard {
            mapTypeButton.setTitle(" Satellite ", for: .normal)
        } else {
            mapTypeButton.setTitle(" Standard ", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !view.subviews.contains(appDelegate.myMapView) {
            view.addSubview(appDelegate.myMapView)
        }
        self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
        
        getCurrentBook()
        getPinsForGlossary()
        addSavedPinsToMap()
        
        for bibleLocation in masterGlossary {
            let name = bibleLocation.name!
            var i = 0
            for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
                if name[name.startIndex] == char {
                    sortedGlossary[i].append(bibleLocation)
                }
                i += 1
            }
        }
        subscribeToKeyboardNotifications()
    }
    
    func getCurrentBook() {
        
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        do {
            let results = try context!.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            for book in results as! [Book] {
                if book.name == "Glossary" {
                    currentBook = book
                    return
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context!) as! Book
        newBook.name = "Glossary"
        currentBook = newBook
        return
        
    }
    
    func getPinsForGlossary() {
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()

        let p = NSPredicate(format: "pinToBook = %@", currentBook!)
        request.predicate = p
        
        pinsForBook = []
        do {
            let results = try context!.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            pinsForBook = results as! [Pin]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func addSavedPinsToMap() {
        
        self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)

        for pin in pinsForBook {
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            annotation.title = pin.title
            appDelegate.myMapView.addAnnotation(annotation)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
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
        
        return sortedGlossary[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        return sortedGlossary.count
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
            cell.setUp(location: sortedGlossary[indexPath.section][indexPath.row])
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
        
        if searchController.isActive {
            var location: BibleLocation!
            if searchController.searchBar.text != "" {
                location = filteredGlossary[indexPath.row] as BibleLocation
            } else {
                location = sortedGlossary[indexPath.section][indexPath.row] as BibleLocation
            }
            appDelegate.myMapView.isHidden = false
            setUpMap(name: location.name!, lat: location.lat, long: location.long)
            savePin(location: location!)
            searchController.dismiss(animated: true, completion: nil)
            searchController.searchBar.text = ""
            y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
            height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
            myTableView.frame = CGRect(x: 0.0, y: y! + height!*0.45, width: screenSize.width, height: height!*0.55)
            mapTypeButton.isHidden = false
            mapTypeButton.isEnabled = true
            self.view.bringSubview(toFront: mapTypeButton)
            myTableView.reloadData()
        } else {
            let location = sortedGlossary[indexPath.section][indexPath.row] as BibleLocation
            setUpMap(name: location.name!, lat: location.lat, long: location.long)
            savePin(location: location)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func savePin(location: BibleLocation) {
        
        let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
        newPin.setValue(location.lat, forKey: "lat")
        newPin.setValue(location.long, forKey: "long")
        newPin.setValue(location.name, forKey: "title")
        newPin.setValue(currentBook, forKey: "pinToBook")
        pinsForBook.append(newPin)

        appDelegate.saveContext()
        
    }
    
    func setUpMap(name: String, lat: Double, long: Double) {
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        appDelegate.myMapView.setCenter(coordinate, animated: true)

        let allAnnotations = appDelegate.myMapView.annotations
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
            appDelegate.myMapView.addAnnotation(annotation)
            appDelegate.myMapView.selectAnnotation(annotation, animated: false)
            
        } else {
            
            appDelegate.myMapView.selectAnnotation(alreadyAddedAnnotation!, animated: false)
            
        }
        
    }

    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins from Map", style: .default) { (action) in
            self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
            for pin in self.pinsForBook {
                self.context!.delete(pin)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        myTableView.frame = CGRect(x: 0.0, y: y! + height!*0.45, width: screenSize.width, height: height!*0.55)
        searchController.searchBar.text = ""
        mapTypeButton.isEnabled = true
        mapTypeButton.isHidden = false
        
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - getKeyboardHeight(notification: notification)
        
        appDelegate.myMapView.isHidden = true
        myTableView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!)
        clearMapButton.isEnabled = false
        mapTypeButton.isEnabled = false
        mapTypeButton.isHidden = true
        myTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        appDelegate.myMapView.isHidden = false
        clearMapButton.isEnabled = true
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
