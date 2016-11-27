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

//IBOutlets********************************************************************************
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var aiv: UIActivityIndicatorView!

//Controller Variables*********************************************************************

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    var chapterTitles = [String]()
    var chapterIndex: Int?
    var book: String?
    var numberOfChapters: Int?
    var lastAnnotation: MKAnnotation?
    var menuView: BTNavigationDropdownMenu? = nil
    var selectedBible: String? = nil
    var locations: [String : [String : [String]]] = [:]
    var glossary: [[String : BibleLocation]] = []
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    var rawText = ""
    
//Life Cycle Functions*********************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Bible Translation
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        if selectedBible == "King James Version" {
            locations = BibleLocationsKJV.Locations
            glossary = BibleLocationsKJV.Glossary
        }
        
        //Set look of screen
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        let screenSize: CGRect = UIScreen.main.bounds
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = screenSize.height - y
        myMapView.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: height/2)
        myTextView.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        
        //Set starting chapter
        if let chapter = defaults.value(forKey: book!) {
            chapterIndex = chapter as? Int
        } else {
            chapterIndex = 1
        }

        //Load saved map dimensions
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

        //Add previously added pins
        getCurrentBook()
        getPinsForBook()
        addSavedPinsToMap()
        
        //Configure swipes
        let swipeLeft = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.left)
        swipeLeft.addTarget(self, action: #selector(MapAndTextViewController.swipeLeft))
        
        let swipeRight = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.right)
        swipeRight.addTarget(self, action: #selector(MapAndTextViewController.swipeRight))
        
        //Set up menu view
        numberOfChapters = Books.booksDictionary[book!]
        for i in 1...numberOfChapters! {
            chapterTitles.append("\(book!) \(String(i))")
        }
        self.menuView = createDropdownMenu(title: "\(book!) \(chapterIndex!)", items: chapterTitles as [AnyObject])
        self.navItem.titleView = menuView

        aiv.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        aiv.isHidden = false
        aiv.startAnimating()
        myTextView.text = ""
        DispatchQueue.main.async {
            self.setUpText()
            self.aiv.stopAnimating()
            self.aiv.isHidden = true
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        myTextView.isScrollEnabled = false
        myTextView.isEditable = false
        myMapView.showsPointsOfInterest = false
    }
    
//Text View********************************************************************************
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let decodedURL = URL.absoluteString.replacingOccurrences(of: "%20", with: " ")
        let letters = BibleLocationsKJV.Letters as NSDictionary
        let firstLetter = decodedURL[decodedURL.startIndex]
        let index = letters[String(firstLetter)] as! Int
        
        if let location = glossary[index][decodedURL] {
            
            setUpMap(name: location.name!, lat: location.lat!, long: location.long!)
        
            let context = appDelegate.managedObjectContext
        
            let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin
            newPin.lat = location.lat!
            newPin.long = location.long!
            newPin.title = location.name!
            newPin.pinToBook = currentBook
            pinsForBook.append(newPin)
        
            appDelegate.saveContext()
        
            return true
            
        } else {
            return false
        }
        
    }
    
//IBActions********************************************************************************
    
    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins from Map", style: .default) { (action) in
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
    
//Map View*********************************************************************************
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        lastAnnotation = view.annotation
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let locationData =
            ["lat":myMapView.centerCoordinate.latitude
            , "long":myMapView.centerCoordinate.longitude
            , "latDelta":myMapView.region.span.latitudeDelta
            , "longDelta":myMapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: "\(book) location")

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

//Helper Functions*************************************************************************

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
        
        if !shouldAddAnnotation {
            myMapView.removeAnnotation(alreadyAddedAnnotation!)
        }
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = name
        myMapView.addAnnotation(annotation)
        myMapView.selectAnnotation(annotation, animated: false)
        lastAnnotation = annotation
        
    }

    func setUpText() {
        var verseNumbers = ["\(chapterIndex!):1"]
        if verseNumbers.count == 1 {
            for i in 2...100 {
                verseNumbers.append("\(chapterIndex!):\(i)")
            }
        }
        
        let bible = selectedBible?.stringByRemovingWhitespaces
        let path = Bundle.main.path(forResource: book, ofType: "txt", inDirectory: bible)
        print(path!)
        
        do {
            rawText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {
        }
        
        let totalChars = rawText.characters.count
        
        if let theRange = rawText.range(of: rawText) {
            
            let startString = "\(chapterIndex!):1"
            let endString = "\(chapterIndex!+1):1"
            let startRange = (rawText as NSString).range(of: startString)
            let endRange = (rawText as NSString).range(of: endString)
            let low = rawText.index(theRange.lowerBound, offsetBy: startRange.location)
            
            if endRange.location > totalChars {
                rawText = rawText.substring(from: low)
            } else {
                let high = rawText.index(theRange.lowerBound, offsetBy: endRange.location)
                let subRange = low ..< high
                rawText = rawText[subRange]
            }
        }
        
        rawText = rawText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let attributedText = NSMutableAttributedString(string: rawText as String)
        let allTextRange = (rawText as NSString).range(of: rawText)
        
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Light", size:16.0)!, range: allTextRange)
        
        let places = locations[book!]?[String(describing: chapterIndex!)]!
        
        if (places?.count)! > 0 {
            
            for place in places! {
                
                var range = (rawText as NSString).range(of: place)
                var offset = 0
                let totalCharacters = rawText.characters.count
                
                while range.location < totalChars {
                    
                    let value = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                    attributedText.addAttribute(NSLinkAttributeName, value: value!, range: range)
                    
                    offset = range.location + 1
                    let startIndex = rawText.index(rawText.startIndex, offsetBy: offset)
                    let newText = rawText.substring(from: startIndex)
                    
                    range = (newText as NSString).range(of: place)
                    
                    if range.location < totalChars {
                        if offset + range.location < totalCharacters {
                            range = NSMakeRange(offset + range.location, range.length)
                        }
                    }
                }
            }
        }
        
        var charactersRemoved = 0
        var replacementString = ""
        for verse in verseNumbers {
            let range = (rawText as NSString).range(of: verse)
            
            let a = String(describing: chapterIndex!).characters.count + 1
            
            if range.location < totalChars {
                let start = range.location - charactersRemoved
                let len = range.length
                let toDelete = NSMakeRange(start, a)
                var newRange = NSMakeRange(start, len - a)
                if charactersRemoved == 0 {
                    replacementString = ""
                } else {
                    replacementString = "\n\n"
                    if a == 2 {
                        newRange = NSMakeRange(start + a, len - a)
                    } else if a == 3 {
                        newRange = NSMakeRange(start + a - 1, len - a)
                    } else {
                        newRange = NSMakeRange(start + a - 2, len - a)
                    }
                }
                attributedText.replaceCharacters(in: toDelete, with: replacementString)
                attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:12.0)!, range: newRange)
            }
            charactersRemoved = charactersRemoved + a - replacementString.characters.count
        }
        
        myTextView.attributedText = attributedText
        myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        
    }
    
    func swipeLeft() {
        if chapterIndex != numberOfChapters { chapterIndex! += 1 } else { return }
        swipeActions()
    }
    
    func swipeRight() {
        if chapterIndex != 1 { chapterIndex! -= 1 } else { return }
        swipeActions()
    }
    
    func swipeActions() {
        self.menuView = createDropdownMenu(title: "\(book!) \(chapterIndex!)", items: chapterTitles as [AnyObject])
        self.navItem.titleView = menuView
        setUpText()
        
        if let lastAnnotation = lastAnnotation {
            myMapView.selectAnnotation(lastAnnotation, animated: false)
        }
        
    }
    
    func addSwipeFunction(direction: UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        self.view.addGestureRecognizer(swipe)
        return swipe
    }
    
    func createDropdownMenu(title: String, items: [AnyObject]) -> BTNavigationDropdownMenu {
        let dropdownMenu = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                    containerView: self.navigationController!.view,
                                                    title: title,
                                                    items: items)
        
        dropdownMenu.arrowTintColor = UIColor.black
        dropdownMenu.shouldChangeTitleText = true
        dropdownMenu.navigationBarTitleFont = UIFont(name: "Papyrus", size: 23.0)
        
        dropdownMenu.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.chapterIndex = indexPath + 1
            self.setUpText()
        }
        return dropdownMenu
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
}

extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined(separator: "")
    }
}

