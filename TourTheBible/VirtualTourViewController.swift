//
//  VirtualTourViewController.swift
//  TourTheBible
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
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var noConnectionLabel: UILabel!
    
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
    var tour: String?
    
    var sites: [[String]] = []
    var days: [String] = []
    var hotels: [[String]] = []
    var stays: [String] = []
    var hotelLocations: [[Any]] = []
    var hotelNumbers: [String] = []
    var hotelWebsites: [String] = []
    
    let colors = [UIColor.red
        ,UIColor.orange
        ,UIColor.yellow
        ,UIColor.green
        ,UIColor.blue
        ,UIColor.purple
        ,UIColor.brown
        ,UIColor.white
        ,UIColor.gray
    ]
    
    override func viewDidLoad() {
        
        context = appDelegate.managedObjectContext
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
        
        appDelegate.myMapView.delegate = self
        
        appDelegate.myMapView.mapType = MKMapType.standard
        appDelegate.myMapView.isHidden = false
        view.addSubview(appDelegate.myMapView)
        myTableView.isHidden = true
        
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        
        mapTypeButton.setTitle(" Satellite ", for: .normal)
        mapTypeButton.layer.borderWidth = 1
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.view.bringSubview(toFront: mapTypeButton)
        
        noConnectionLabel.text = "No Internet Connection"
        noConnectionLabel.textAlignment = .center
        noConnectionLabel.isHidden = true
        
        adjustSubviews()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appDelegate.myMapView.mapType == MKMapType.standard {
            mapTypeButton.setTitle(" Satellite ", for: .normal)
        } else {
            mapTypeButton.setTitle(" Standard ", for: .normal)
        }
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
        let tabBarHeight = (tabBarController?.tabBar.frame.size.height)!
        height = screenSize.height - y! - tabBarHeight
        
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: (height!+tabBarHeight)*0.45)
        segmentedControl.frame = CGRect(x: 5, y: y! + (height!+tabBarHeight)*0.45 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: y! + (height!+tabBarHeight)*0.45 + 40, width: screenSize.width, height: (height!+tabBarHeight)*0.55 - 40 - tabBarHeight)
        aiv.frame = CGRect(x: (screenSize.width/2) - 10, y: y! + (height!+tabBarHeight)*0.45 + 55, width: 20, height: 20)
        noConnectionLabel.frame = CGRect(x: 0.0 , y: y! + (height!+tabBarHeight)*0.45 + 55, width: screenSize.width, height: 100)
        self.view.bringSubview(toFront: mapTypeButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    func getData() {
        
        aiv.isHidden = false
        aiv.startAnimating()
        FirebaseClient.sharedInstance.getTour(name: tour!, completion: { (tour, error) -> () in
            if let tour = tour {
                let hotelDict = tour["Hotels"] as! NSDictionary
                let siteDict =  tour["Sites"] as! NSDictionary
                var dayKeys = siteDict.allKeys as! [String]
                dayKeys.sort()
                
                self.stays = hotelDict.allKeys as! [String]
                self.stays.sort()
                self.days = siteDict.allKeys as! [String]
                self.days.sort()
                
                for key in dayKeys {
                    let day = siteDict[key] as! NSDictionary
                    var keys = day.allKeys as! [String]
                    keys.sort()
                    var places: [String] = []
                    for key in keys {
                        let place = day[key] as! String
                        places.append(place)
                    }
                    self.sites.append(places)
                }
                
                for key in self.stays {
                    let hotelInfo = hotelDict[key] as! NSDictionary
                    let keys = hotelInfo.allKeys as! [String]
                    for key in keys {
                        let hotelName = key
                        let hotelArray = [hotelName]
                        self.hotels.append(hotelArray)
                        let hotelData = hotelInfo[key] as! NSDictionary
                        let hotelLocationArray = [hotelName,hotelName,hotelData["lat"]!,hotelData["long"]!]
                        self.hotelLocations.append(hotelLocationArray)
                        self.hotelNumbers.append(hotelData["phone"]! as! String)
                        self.hotelWebsites.append(hotelData["website"] as! String)
                    }
                }
                
                self.myTableView.isHidden = false
                self.segmentedControl.isUserInteractionEnabled = true
                self.myTableView.reloadData()
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.segmentedControl.isUserInteractionEnabled = false
        
        if FirebaseClient.sharedInstance.hasConnectivity() {
            noConnectionLabel.isHidden = true
            getData()
        } else {
            noConnectionLabel.isHidden = false
            myTableView.isHidden = true
            aiv.isHidden = true
        }
        
        if !view.subviews.contains(appDelegate.myMapView) {
            view.addSubview(appDelegate.myMapView)
        }
        appDelegate.myMapView.isHidden = false
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
    
    func formatDate(date: String) -> String {
        var month = date[date.index(date.startIndex, offsetBy: 4) ..< date.index(date.startIndex, offsetBy: 6)]
        var day = date[date.index(date.startIndex, offsetBy: 6) ..< date.index(date.startIndex, offsetBy: 8)]
        let year = date[date.index(date.startIndex, offsetBy: 0) ..< date.index(date.startIndex, offsetBy: 4)]
        var month2 = ""
        var day2 = ""
        for c in month.characters {
            if c == "0" && month2 == "" { continue }
            month2.append(c)
        }
        for d in day.characters {
            if d == "0" && day2 == "" { continue }
            day2.append(d)
        }
        return "\(month2)/\(day2)/\(year)"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            var formattedDays: [String] = []
            for date in days {
                let formattedDate = formatDate(date: date)
                formattedDays.append(formattedDate)
            }
            return formattedDays[section]
        } else {
            var formattedStays: [String] = []
            for stay in stays {
                let stayComponents = stay.characters.split{$0 == "-"}.map(String.init)
                let formattedStay = "\(formatDate(date: stayComponents[0]))-\(formatDate(date: stayComponents[1]))"
                formattedStays.append(formattedStay)
            }
            return formattedStays[section]
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BibleLocation")
            
            let p = NSPredicate(format: "name = %@", siteToPlot)
            fetchRequest.predicate = p
            
            var bibleLocations: [BibleLocation]?
            do {
                let results = try context!.fetch(fetchRequest)
                bibleLocations = results as? [BibleLocation]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            if bibleLocations?.count != 0 {
            
                let bibleLocation = bibleLocations?[0]
                
                setUpMap(name: (bibleLocation?.name!)!, lat: (bibleLocation?.lat)!, long: (bibleLocation?.long)!)
                        
                let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
                newPin.setValue(bibleLocation?.lat, forKey: "lat")
                newPin.setValue(bibleLocation?.long, forKey: "long")
                newPin.setValue(bibleLocation?.name, forKey: "title")
                newPin.setValue(currentBook, forKey: "pinToBook")
                pinsForBook.append(newPin)
                        
                appDelegate.saveContext()
                
            } else {
                print(siteToPlot)
            }

        } else {
            let siteToPlot = hotels[section][row]
            for location in hotelLocations {
                if siteToPlot == String(describing: location[0]) {
                    if String(describing: location[2]) != "" {
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
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        
        self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
        
        getCurrentBook()
        getPinsForVirtualTour()
        addSavedPinsToMap()
        
        myTableView.reloadData()
        myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
    
}
