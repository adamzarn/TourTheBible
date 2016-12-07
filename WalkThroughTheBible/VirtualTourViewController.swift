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
import CoreData

class VirtualTourViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let screenSize: CGRect = UIScreen.main.bounds
    var y: CGFloat?
    var height: CGFloat?
    var selectedBible: String? = nil
    var site: String?
    var resume: Bool = true
    var siteCount: Int = 1
    var hotelCount: Int = 1
    var currentBook: Book? = nil
    var pinsForBook = [Pin]()
    
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
        
        context = appDelegate.managedObjectContext
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        appDelegate.myMapView.delegate = self
        
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!/2)
        appDelegate.myMapView.mapType = MKMapType.standard
        view.addSubview(appDelegate.myMapView)
        segmentedControl.frame = CGRect(x: 5, y: y! + height!/2 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: y! + height!/2 + 40, width: screenSize.width, height: height!/2 - 40)
        
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !view.subviews.contains(appDelegate.myMapView) {
            view.addSubview(appDelegate.myMapView)
        }
        self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
        getCurrentBook()
        getPinsForVirtualTour()
        addSavedPinsToMap()
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
            for item in data[i] {
                if title!.contains(item) {
                    pinView.pinTintColor = colors[i]
                }
            }
        }
        
        pinView.canShowCallout = true
        pinView.annotation = annotation

        return pinView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            siteCount = 0
        } else {
            hotelCount = 0
        }
        for i in 0 ..< indexPath.section {
            if segmentedControl.selectedSegmentIndex == 0 {
                siteCount += sites[i].count
            } else {
                hotelCount += hotels[i].count
            }
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            siteCount += indexPath.row + 1
        } else {
            hotelCount += indexPath.row + 1
        }
        plot(section:indexPath.section,row:indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        updateCount()
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
    
    func getCurrentBook() {
        
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        var name: String?
        if segmentedControl.selectedSegmentIndex == 0 {
            name = "Sites"
        } else {
            name = "Hotels"
        }
        
        do {
            let results = try context!.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            for book in results as! [Book] {
                if book.name == name {
                    currentBook = book
                    return
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context!) as! Book
        newBook.name = name
        currentBook = newBook
        return
        
    }
    
    func getPinsForVirtualTour() {
        
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
    
    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins from Map", style: .default) { (action) in
            self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
            for pin in self.pinsForBook {
                self.context!.delete(pin)
            }
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.siteCount = 1
            } else {
                self.hotelCount = 1
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        var index = 1
        var localCount = 0
        
        var data = sites
        localCount = siteCount
        if segmentedControl.selectedSegmentIndex == 1 {
            data = hotels
            localCount = hotelCount
        }
        
        for i in 0 ..< data.count {
            for j in 0 ..< data[i].count {
                let section = i
                let row = j
                if index == localCount {
                    plot(section:section,row:row)
                    updateCount()
                    return
                }
                index += 1
            }
        }
    }
    
    func updateCount() {
        var localCount = 0
        
        var data = sites
        localCount = siteCount
        if segmentedControl.selectedSegmentIndex == 1 {
            data = hotels
            localCount = hotelCount
        }
        var totalItems = 0
        for item in data {
            totalItems += item.count
        }
        
        localCount += 1
        if localCount - 1 == totalItems {
            localCount = 1
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            siteCount = localCount
        } else {
            hotelCount = localCount
        }
        
        
    }
    
    func plot(section:Int,row:Int) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let siteToPlot = sites[section][row]
            for location in tourLocations {
                if siteToPlot == String(describing: location[0]) {
                    setUpMap(name: String(describing: location[1]), lat: location[2] as! Double, long: location[3] as! Double)
                    let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
                    newPin.setValue(location[2], forKey: "lat")
                    newPin.setValue(location[3], forKey: "long")
                    newPin.setValue(location[1], forKey: "title")
                    newPin.setValue(currentBook, forKey: "pinToBook")
                    pinsForBook.append(newPin)
                    
                    appDelegate.saveContext()
                }
            }
        } else {
            let siteToPlot = hotels[section][row]
            for location in hotelLocations {
                if siteToPlot == String(describing: location[0]) {
                    setUpMap(name: String(describing: location[1]), lat: location[2] as! Double, long: location[3] as! Double)
                    let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
                    newPin.setValue(location[2], forKey: "lat")
                    newPin.setValue(location[3], forKey: "long")
                    newPin.setValue(location[1], forKey: "title")
                    newPin.setValue(currentBook, forKey: "pinToBook")
                    pinsForBook.append(newPin)
                    
                    appDelegate.saveContext()
                }
            }

        }
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        
        self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
        
        getCurrentBook()
        getPinsForVirtualTour()
        addSavedPinsToMap()
        
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
    
    let tourLocations = [
        ["Caesarea","Caesarea", 32.499545, 34.892185]
        ,["Mount Carmel","Mount Carmel", 32.729350, 35.049790]
        ,["Megiddo","Megiddo",32.584183,35.182292]
        ,["Mount Arbel","Mount Arbel",32.823037,35.499315]
        ,["Sea of Galilee","Sea of Galilee",32.806776,35.589361]
        ,["Mount of Beatitudes","Mount of Beatitudes",32.881956,35.557337]
        ,["Capernaum","Capernaum",32.880594,35.575158]
        ,["Magdala","Magdala",32.847335,35.522936]
        ,["Ancient Galilee Boat","Ancient Galilee Boat",32.844281,35.525166]
        ,["Jordan River","Jordan River",32.711111,35.571389]
        ,["Chorazin","Chorazin",32.909092,35.552923]
        ,["Dan","Dan",33.24866,35.652483]
        ,["Caesarea Philippi","Caesarea Philippi",33.24806,35.694637]
        ,["Golan Heights","Golan Heights",32.800076,35.937301]
        ,["Kursi","Kursi",32.838888,35.665054]
        ,["Spring of Harod","Spring of Harod",32.5506,35.3569]
        ,["Bethshan","Bethshan",32.504238,35.503077]
        ,["Jericho","Jericho",31.870601,35.443864]
        ,["Wadi Qilt","Wadi Qilt",31.844316,35.414257]
        ,["Qumran","Qumran",31.740833,35.458611]
        ,["Masada","Masada",31.315556,35.353889]
        ,["Ein Gedi","Ein Gedi",31.461525,35.392411]
        ,["Dead Sea","Dead Sea",31.538593,35.482268]
        ,["Jerusalem","Jerusalem",31.777444,35.234935]
        ,["Mount Scopus","Mount Scopus",31.7925,35.244167]
        ,["Jaffa Gate","Jaffa Gate",31.776528,35.227694]
        ,["Southern Temple Steps","Southern Temple Steps",31.775761,35.236106]
        ,["Wailing Wall","Wailing Wall",31.7767,35.2345]
        ,["City of David","City of David",31.773611,35.235556]
        ,["Upper Room","Upper Room",31.771461,35.229324]
        ,["Bethlehem","Bethlehem",31.705361,35.210266]
        ,["Shepherds Field","Shepherds Field",31.704323,35.2077]
        ,["Herodium","Herodium",31.665833,35.241389]
        ,["Church of All Nations","Church of All Nations",31.779227,35.239628]
        ,["Garden of Gethsemane","Garden of Gethsemane",31.77966,35.239605]
        ,["Mount of Olives","Mount of Olives",31.778095,35.247198]
        ,["Beersheba","Beersheba",31.244952,34.840889]
        ,["Valley of Elah","Valley of Elah",31.690629,34.963136]
        ,["Beth Shemesh","Beth Shemesh",31.752748,34.976609]
        ,["Temple Mount","Temple Mount",31.77765,35.23547]
        ,["Pool of Bethesda","Pool of Bethesda",31.781248,35.236613]
        ,["Yad Vashem","Yad Vashem",31.774167,35.175556]
        ,["Church of the Holy Sepulchre","Church of the Holy Sepulchre",31.778444,35.22975]
        ,["Garden Tomb" ,"Garden Tomb",31.783853,35.229978]]
    
    
    let hotelLocations = [["Dan Panorama Tel Aviv","Dan Panorama Tel Aviv",32.064581,34.763070]
        ,["Gai Beach Hotel","Gai Beach Hotel",32.779675,35.544929]
        ,["Isrotel Dead Sea","Isrotel Dead Sea",31.192871,35.361051]
        ,["Dan Jerusalem","Dan Jerusalem",31.797884,35.235659]]
    
}
