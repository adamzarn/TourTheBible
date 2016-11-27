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
    var site: String?
    var resume: Bool = true
    var count: Int = 1
    
    let sites = [
        ["Caesarea","Mount Carmel","Megiddo","Mount Arbel"]
        ,["Sea of Galilee","Mount of Beatitudes","Capernaum","Magdala","Ancient Galilee Boat","Jordan River"]
        ,["Chorazin","Dan","Caesarea Philippi","Golan Heights","Kursi"]
        ,["Spring of Harod","Bethshan","Jericho","Wadi Qilt","Qumran"]
        ,["Masada","Ein Gedi","Dead Sea"]
        ,["Jerusalem","Mount Scopus","Jaffa Gate","Southern Temple Steps","Wailing Wall","City of David","Upper Room"]
        ,["Bethlehem","Shepherds Field","Herodium","Church of All Nations","Garden of Gethsemane"]
        ,["Mount of Olives","Beersheba","Valley of Elah","Beth Shemesh"]
        ,["Temple Mount","Pool of Bethesda","Yad Vashem","Church of the Holy Sepulchre","Garden Tomb"]
    ]
    let days = ["6/5/2016","6/6/2016","6/7/2016","6/8/2016","6/9/2016","6/10/2016","6/11/2016","6/12/2016","6/13/2016"]
    
    let hotels = [
                ["Dan Panorama Tel Aviv"]
                ,["Gai Beach Hotel"]
                ,["Isrotel Dead Sea"]
                ,["Dan Jerusalem"]
    
    ]
    let stays = ["6/4/2016 - 6/5/2016","6/5/2016 - 6/8/2016","6/8/2016 - 6/10/2016","6/10/2016 - 6/14/2016"]
    
    let colors = [UIColor.red
        ,UIColor.orange
        ,UIColor.yellow
        ,UIColor.green
        ,UIColor.blue
        ,UIColor.purple
        ,UIColor.brown
        ,UIColor.white
        ,UIColor.gray]
    
    override func viewDidLoad() {
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        myMapView.delegate = self
        
        myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!/2)
        segmentedControl.frame = CGRect(x: 5, y: y! + height!/2 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2 + 40, width: screenSize.width, height: height!/2 - 40)
        
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        
        if selectedBible == "King James Version" {
            glossary = BibleLocationsKJV.Glossary
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return sites[section].count
        } else {
            return hotels[section].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return days.count
        } else {
            return stays.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            return days[section]
        } else {
            return stays[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.textLabel!.text = sites[indexPath.section][indexPath.row]
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.textLabel!.text = hotels[indexPath.section][indexPath.row]
            cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let call = UIAlertAction(title: "Call", style: .default) { (action) in
            self.call(phoneNumber: self.hotelNumbers[indexPath.section])
        }
        let visitWebsite = UIAlertAction(title: "Visit Website", style: .default) { (action) in
            self.visit(website: self.hotelWebsites[indexPath.section])
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(call)
        alertController.addAction(visitWebsite)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView()
        let title = annotation.title!
        
        var data = sites
        if segmentedControl.selectedSegmentIndex == 1 {
            data = hotels
        }
        
        for i in 0 ..< data.count {
            let space = (title! as NSString).range(of: " ")
            let index = title!.index(title!.startIndex, offsetBy: space.location + 1)
            if data[i].contains(title!.substring(from:index)) {
                pinView.pinTintColor = colors[i]
            }
        }
        
        pinView.canShowCallout = true
        pinView.annotation = annotation

        return pinView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        count = 0
        for i in 0 ..< indexPath.section {
            if segmentedControl.selectedSegmentIndex == 0 {
                count += sites[i].count
            } else {
                count += hotels[i].count
            }
        }
        count += indexPath.row + 1
        plot(section:indexPath.section,row:indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        updateCount()
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
            annotation.title = "\(self.count). " + name
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
    
    @IBAction func playButtonPressed(_ sender: Any) {
        var index = 1
        var data = sites
        if segmentedControl.selectedSegmentIndex == 1 {
            data = hotels
        }
        
        for i in 0 ..< data.count {
            for j in 0 ..< data[i].count {
                let section = i
                let row = j
                if index == count {
                    plot(section:section,row:row)
                    updateCount()
                    return
                }
                index += 1
            }
        }
    }
    
    func updateCount() {
        var data = sites
        if segmentedControl.selectedSegmentIndex == 1 {
            data = hotels
        }
        var totalItems = 0
        for item in data {
            totalItems += item.count
        }
        count += 1
        if count - 1 == totalItems {
            count = 1
        }
    }
    
    func plot(section:Int,row:Int) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let siteToPlot = sites[section][row]
            let location = tourLocations[siteToPlot]
            setUpMap(name: (location?.name!)!, lat: (location?.lat!)!, long: (location?.long!)!)
        } else {
            let siteToPlot = hotels[section][row]
            let location = hotelLocations[siteToPlot]
            setUpMap(name: (location?.name!)!, lat: (location?.lat!)!, long: (location?.long!)!)
        }
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.myMapView.removeAnnotations(self.myMapView.annotations)
        myTableView.reloadData()
    }
    
    private func call(phoneNumber:String) {
        if let phoneCallURL: NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL)
            }
        }
    }
    
    private func visit(website:String) {
        UIApplication.shared.openURL(NSURL(string:website) as! URL)
    }
    
    let hotelNumbers = ["1-800-223-7773","9724-670-0700","9728-638-7797","9722-533-1234"]
    
    let hotelWebsites = [
    "http://www.danhotels.com/telavivhotels/danpanoramatelavivhotel/"
    ,"http://www.gaibeachhotel.com/"
    ,"https://www.isrotel.com/isrotel-dead-sea"
    ,"http://www.danhotels.co.il/JerusalemHotels/DanJerusalemHotel/"
    ]
    
    let tourLocations = ["Caesarea" : BibleLocation(name: "Caesarea", lat: 32.499545, long: 34.892185)
    ,"Mount Carmel" : BibleLocation(name: "Mount Carmel", lat: 32.729350, long: 35.049790)
    ,"Megiddo" : BibleLocation(name: "Megiddo", lat: 32.584183, long: 35.182292)
    ,"Mount Arbel" : BibleLocation(name: "Mount Arbel", lat: 32.823037, long: 35.499315)
    ,"Sea of Galilee" : BibleLocation(name: "Sea of Galilee", lat: 32.806776, long: 35.589361)
    ,"Mount of Beatitudes" : BibleLocation(name: "Mount of Beatitudes", lat: 32.881956, long: 35.557337)
    ,"Capernaum" : BibleLocation(name: "Capernaum", lat: 32.880594, long: 35.575158)
    ,"Magdala" : BibleLocation(name: "Magdala", lat: 32.847335, long: 35.522936)
    ,"Ancient Galilee Boat" : BibleLocation(name: "Ancient Galilee Boat", lat: 32.844281, long: 35.525166)
    ,"Jordan River" : BibleLocation(name: "Jordan River", lat: 32.711111, long: 35.571389)
    ,"Chorazin" : BibleLocation(name: "Chorazin", lat: 32.909092, long: 35.552923)
    ,"Dan" : BibleLocation(name: "Dan", lat: 33.248660, long: 35.652483)
    ,"Caesarea Philippi" : BibleLocation(name: "Caesarea Philippi", lat: 33.248060, long: 35.694637)
    ,"Golan Heights" : BibleLocation(name: "Golan Heights", lat: 32.800076, long: 35.937301)
    ,"Kursi" : BibleLocation(name: "Kursi", lat: 32.838888, long: 35.665054)
    ,"Spring of Harod" : BibleLocation(name: "Spring of Harod", lat: 32.5506, long: 35.3569)
    ,"Bethshan" : BibleLocation(name: "Bethshan", lat: 32.504238, long: 35.503077)
    ,"Jericho" : BibleLocation(name: "Jericho", lat: 31.870601, long: 35.443864)
    ,"Wadi Qilt" : BibleLocation(name: "Wadi Qilt", lat: 31.844316, long: 35.414257)
    ,"Qumran" : BibleLocation(name: "Qumran", lat: 31.740833, long: 35.458611)
    ,"Masada" : BibleLocation(name: "Masada", lat: 31.315556, long: 35.353889)
    ,"Ein Gedi" : BibleLocation(name: "Ein Gedi", lat: 31.461525, long: 35.392411)
    ,"Dead Sea" : BibleLocation(name: "Dead Sea", lat: 31.538593, long: 35.482268)
    ,"Jerusalem" : BibleLocation(name: "Jerusalem", lat: 31.777444, long: 35.234935)
    ,"Mount Scopus" : BibleLocation(name: "Mount Scopus", lat: 31.7925, long: 35.244167)
    ,"Jaffa Gate" : BibleLocation(name: "Jaffa Gate", lat: 31.776528, long: 35.227694)
    ,"Southern Temple Steps" : BibleLocation(name: "Southern Temple Steps", lat: 31.775761, long: 35.236106)
    ,"Wailing Wall" : BibleLocation(name: "Wailing Wall", lat: 31.7767, long: 35.2345)
    ,"City of David" : BibleLocation(name: "City of David", lat: 31.773611, long: 35.235556)
    ,"Upper Room" : BibleLocation(name: "Upper Room", lat: 31.771461, long: 35.229324)
    ,"Bethlehem" : BibleLocation(name: "Bethlehem", lat: 31.705361, long: 35.210266)
    ,"Shepherds Field" : BibleLocation(name: "Shepherds Field", lat: 31.704323, long: 35.207700)
    ,"Herodium" : BibleLocation(name: "Herodium", lat: 31.665833, long: 35.241389)
    ,"Church of All Nations" : BibleLocation(name: "Church of All Nations", lat: 31.779227, long: 35.239628)
    ,"Garden of Gethsemane" : BibleLocation(name: "Garden of Gethsemane", lat: 31.779660, long: 35.239605)
    ,"Mount of Olives" : BibleLocation(name: "Mount of Olives", lat: 31.778095, long: 35.247198)
    ,"Beersheba" : BibleLocation(name: "Beersheba", lat: 31.244952, long: 34.840889)
    ,"Valley of Elah" : BibleLocation(name: "Valley of Elah", lat: 31.690629, long: 34.963136)
    ,"Beth Shemesh" : BibleLocation(name: "Beth Shemesh", lat: 31.752748, long: 34.976609)
    ,"Temple Mount" : BibleLocation(name: "Temple Mount", lat: 31.77765, long: 35.23547)
    ,"Pool of Bethesda" : BibleLocation(name: "Pool of Bethesda", lat: 31.781248, long: 35.236613)
    ,"Yad Vashem" : BibleLocation(name: "Yad Vashem", lat: 31.774167, long: 35.175556)
    ,"Church of the Holy Sepulchre" : BibleLocation(name: "Church of the Holy Sepulchre", lat: 31.778444, long: 35.22975)
    ,"Garden Tomb" : BibleLocation(name: "Garden Tomb", lat: 31.783853, long: 35.229978)]
    
    let hotelLocations = ["Dan Panorama Tel Aviv" : BibleLocation(name: "Dan Panorama Tel Aviv", lat: 32.064581, long: 34.763070)
    ,"Gai Beach Hotel" : BibleLocation(name: "Gai Beach Hotel", lat: 32.779675, long: 35.544929)
    ,"Isrotel Dead Sea" : BibleLocation(name: "Isrotel Dead Sea", lat: 31.192871, long: 35.361051)
    ,"Dan Jerusalem" : BibleLocation(name: "Dan Jerusalem", lat: 31.797884, long: 35.235659)]
    
}
