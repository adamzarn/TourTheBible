//
//  MapAndTextViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/12/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import BTNavigationDropdownMenu
import CoreData

class MapAndTextViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!

    var chapterTitles = [String]()
    var lastAnnotation: MKAnnotation?

    var menuView: BTNavigationDropdownMenu? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    var chapterIndex: Int?
    var book: String?
    var numberOfChapters: Int?
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    var verseNumbers = ["[1]"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        let screenSize: CGRect = UIScreen.main.bounds
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = screenSize.height - y
        
        myMapView.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: height/2)
        myTextView.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        
        print(screenSize.height)
        print(height)
        print(height/2)
        
        
        if let chapter = defaults.value(forKey: book!) {
            chapterIndex = chapter as? Int
        } else {
            chapterIndex = 1
        }

        if let location = defaults.dictionary(forKey: "\(book) location") {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location["lat"] as! Double, location["long"] as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(location["latDelta"] as! Double, location["longDelta"] as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(center, span)
            myMapView.setRegion(region, animated: true)
            myMapView.setCenter(center, animated: false)
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
            myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        }
        
        getCurrentBook()
        getPinsForBook()
        addSavedPinsToMap()
        
        numberOfChapters = (Books.booksDictionary[book!]?.count)!

        self.automaticallyAdjustsScrollViewInsets = false
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.addTarget(self, action: #selector(MapAndTextViewController.swipeLeft))
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.addTarget(self, action: #selector(MapAndTextViewController.swipeRight))
        self.view.addGestureRecognizer(swipeRight)
        
        for i in 1...numberOfChapters! {
            chapterTitles.append("\(book!) \(String(i))")
        }
        
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: "\(book!) \(chapterIndex!)",
                                                items: chapterTitles as [AnyObject])

        self.navItem.titleView = menuView
        menuView!.arrowTintColor = UIColor.black
        menuView!.shouldChangeTitleText = true
        menuView!.navigationBarTitleFont = UIFont(name: "Papyrus", size: 23.0)
        
        menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.chapterIndex = indexPath + 1
            self.setUpText()
        }
        
        setUpText()
    
    }
    
    func getCurrentBook() {
    
        let context =  appDelegate.managedObjectContext
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        do {
            let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            for book in results as! [Book] {
                if book.name == self.book! {
                    currentBook = book
                    return
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context) as! Book
        newBook.name = book
        currentBook = newBook
        return

    }
    
    func getPinsForBook() {
        
        let context = appDelegate.managedObjectContext
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        print(currentBook!.name!)
        let p = NSPredicate(format: "pinToBook = %@", currentBook!)
        request.predicate = p
        
        pinsForBook = []
        do {
            let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            pinsForBook = results as! [Pin]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func addSavedPinsToMap() {
        for pin in pinsForBook {
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            annotation.title = pin.title
            myMapView.addAnnotation(annotation)

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        myTextView.isScrollEnabled = false
        myTextView.isEditable = false
        myMapView.showsPointsOfInterest = false

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myTextView.isScrollEnabled = true
        myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if menuView!.isShown == true {
            menuView!.hide()
        }
        let defaults = UserDefaults.standard
        defaults.set(chapterIndex, forKey: book!)
    }
    
    func swipeLeft() {
        
        if chapterIndex != numberOfChapters {
            chapterIndex! += 1
        } else {
            return
        }
        
        swipeActions()
        
    }
    
    func swipeRight() {
        
        if chapterIndex != 1 {
            chapterIndex! -= 1
        } else {
            return
        }
        
        swipeActions()

    }
    
    func swipeActions() {
        
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                 containerView: self.navigationController!.view,
                                                 title: "\(book!) \(chapterIndex!)",
            items: chapterTitles as [AnyObject])
        self.navItem.titleView = menuView
        menuView!.arrowTintColor = UIColor.black
        menuView!.shouldChangeTitleText = true
        menuView!.navigationBarTitleFont = UIFont(name: "Papyrus", size: 23.0)
        
        menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.chapterIndex = indexPath + 1
            self.setUpText()
        }
        setUpText()
        
        if let lastAnnotation = lastAnnotation {
            myMapView.selectAnnotation(lastAnnotation, animated: false)
        }
        
    }


    func setUpText() {
        
        if verseNumbers.count == 1 {
            for i in 2...100 {
                verseNumbers.append("[\(i)]")
            }
        }
        
        let text = Books.booksDictionary[book!]![chapterIndex!-1]
        let attributedText = NSMutableAttributedString(string: text as String)
        let allTextRange = (text as NSString).range(of: text)

        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Light", size:16.0)!, range: allTextRange)
        
        let dictionary = BibleLocations.Locations[book!]?[String(describing: chapterIndex!)]! as! NSDictionary
        //let dictionary = BibleLocations.Glossary as! NSDictionary
        
        if dictionary.count > 0 {

            let placesArray = dictionary.allKeys as! [String]
            
            for place in placesArray {
                
                var range = (text as NSString).range(of: place)
                var offset = 0
                let totalCharacters = text.characters.count
                
                while range.location < 10000000 {
                    
                    let value = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                    attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                    attributedText.addAttribute(NSLinkAttributeName, value: value!, range: range)
                    
                    offset = range.location + 1
                    let startIndex = text.index(text.startIndex, offsetBy: offset)
                    let newText = text.substring(from: startIndex)
                    
                    range = (newText as NSString).range(of: place)

                    if range.location < 10000000 {
                        if offset + range.location < totalCharacters {
                            range = NSMakeRange(offset + range.location, range.length)
                        }
                    }
                }
            }
        }
        
        var versesEdited = 0
        for verse in verseNumbers {
            let range = (text as NSString).range(of: verse)
            
            if range.location < 10000000 {
                let start = range.location - versesEdited*2
                let len = range.length
                let firstBracket = NSMakeRange(start, 1)
                let secondBracket = NSMakeRange(start + len - 1, 1)
                let newRange = NSMakeRange(start, len - 2)
                attributedText.replaceCharacters(in: secondBracket, with: "")
                attributedText.replaceCharacters(in: firstBracket, with: "")
                attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:12.0)!, range: newRange)
            }
            versesEdited += 1
        }
        
        myTextView.attributedText = attributedText
        myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)

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
            lastAnnotation = annotation
            
        } else {
            
            myMapView.selectAnnotation(alreadyAddedAnnotation!, animated: false)
            lastAnnotation = alreadyAddedAnnotation
            
        }
    
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let decodedURL = URL.absoluteString.replacingOccurrences(of: "%20", with: " ")
        
        let locationBank = BibleLocations.Locations[book!]?[String(describing: chapterIndex!)]! as! NSDictionary
        //let locationBank = BibleLocations.Locations2 as! NSDictionary
        
        let location = locationBank[decodedURL]! as! BibleLocation
        setUpMap(name: location.name!, lat: location.lat!, long: location.long!, delta: location.delta!)
        
        let context = appDelegate.managedObjectContext
        
        let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin
        newPin.lat = location.lat!
        newPin.long = location.long!
        newPin.title = location.name!
        //let imageData = UIImagePNGRepresentation(UIImage(named: location.name!)!)
        //newPin.image = imageData as NSData?
        newPin.pinToBook = currentBook
        
        pinsForBook.append(newPin)
        
        appDelegate.saveContext()
        
        return true
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        lastAnnotation = view.annotation
    }
    
    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins", style: .default) { (action) in
            self.myMapView.removeAnnotations(self.myMapView.annotations)
            for pin in self.pinsForBook {
                self.appDelegate.managedObjectContext.delete(pin)
            }
            self.appDelegate.saveContext()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)

    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let locationData =
            ["lat":myMapView.centerCoordinate.latitude
            , "long":myMapView.centerCoordinate.longitude
            , "latDelta":myMapView.region.span.latitudeDelta
            , "longDelta":myMapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: "\(book) location")
        print("latDelta: \(myMapView.region.span.latitudeDelta)")
        print("longDelta: \(myMapView.region.span.longitudeDelta)")
    }


}

