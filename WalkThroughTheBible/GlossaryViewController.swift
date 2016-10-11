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

class GlossaryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTableView: UITableView!
    
    var glossary = [[BibleLocation]]()
    let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","Y","Z"]
    
    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        glossary = []
        for letter in BibleLocations.Glossary {
            let letter = letter as NSDictionary
            var locations = letter.allValues as! [BibleLocation]
            locations = locations.sorted { $0.name! < $1.name! }
            glossary.append(locations)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return letters
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return letters.index(of: title)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return glossary[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return glossary.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letters[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GlossaryCell
        
        cell.setUp(location: glossary[indexPath.section][indexPath.row])
        
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
        
        let imageView = UIImageView(image: UIImage(named: annotation.title!!))
        imageView.frame.size = CGSize(width: 40.0, height: 40.0)
        pinView!.leftCalloutAccessoryView = imageView
        
        return pinView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = glossary[indexPath.section][indexPath.row] as BibleLocation
        
        setUpMap(name: location.name!, lat: location.lat!, long: location.long!, delta: location.delta!)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    
}

