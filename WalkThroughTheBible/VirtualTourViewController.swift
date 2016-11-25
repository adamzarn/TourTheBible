//
//  VirtualTourViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 11/24/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class VirtualTourViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let screenSize: CGRect = UIScreen.main.bounds
    var y: CGFloat?
    var height: CGFloat?
    var glossary: [[String : BibleLocation]] = []
    var selectedBible: String? = nil
    
    let sites = [
        ["Caesarea","Mount Carmel","Megiddo","Mount Arbel"]
        ,["Sea of Galilee","Mount of Beatitudes","Capernaum","Magdala","Ancient Galilee Boat","Jordan River"]
        ,["Chorazin","Dan","Caesarea Philippi","Golan Heights","Kursi"]
        ,["Spring of Harod","Bet She'an","Jericho","Wadi Qilt","Qumran"]
        ,["Masada","Ein Gedi","Dead Sea"]
        ,["Jerusalem","Mount Scopus","Jaffa Gate","Southern Temple Steps","Wailing Wall","City of David","Upper Room"]
        ,["Bethlehem","Shepherds Field","Herodium","Church of All Nations","Garden of Gethsemane"]
        ,["Mount of Olives","Beersheba","Valley of Elah","Beth Shemesh"]
        ,["Temple Mount","Pool of Bethesda","Yad Vashem","Church of the Holy Sepulchre","Garden Tomb"]
    ]
    let days = ["6/5/2016","6/6/2016","6/7/2016","6/8/2016","6/9/2016","6/10/2016","6/11/2016","6/12/2016","6/13/2016"]
    
    let hotels = [""]
    let stays = [""]
    
    override func viewDidLoad() {
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!/2)
        print(myMapView.frame)
        segmentedControl.frame = CGRect(x: 5, y: y! + height!/2 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2 + 40, width: screenSize.width, height: height!/2 - 40)
        
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        
        if selectedBible == "King James Version" {
            glossary = BibleLocationsKJV.Glossary
        }

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        cell.textLabel!.text = sites[indexPath.section][indexPath.row]
        
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
        let place = sites[indexPath.section][indexPath.row]
        
        for letter in glossary {
            if let location = letter[place] {
                setUpMap(name: location.name!, lat: location.lat!, long: location.long!)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func setUpMap(name: String, lat: Double, long: Double) {
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        myMapView.setCenter(coordinate, animated: true)
        
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
        let removePins = UIAlertAction(title: "Remove Pins from Map", style: .default) { (action) in
            self.myMapView.removeAnnotations(self.myMapView.annotations)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

