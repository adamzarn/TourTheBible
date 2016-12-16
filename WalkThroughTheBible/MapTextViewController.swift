//
//  MapTextViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 11/30/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

@objc
protocol MapTextViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
}

class MapTextViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {
    
    //IBOutlets********************************************************************************

    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //Controller Variables*********************************************************************
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    var bibleLocations: [BibleLocation]?
    var tappedLocation: String = ""
    var tappedLocationKey: String = ""
    var chapterTitles: [String] = []
    var chapterAppearances = [[String]](repeating: [], count: 66)
    var subtitles = [[String]](repeating: [], count: 66)
    var bookAppearances: [String] = []
    var completeRawText: String?
    var rawText: String?
    var attributedText: NSMutableAttributedString?
    var chapterIndex: Int?
    var book: String?
    var numberOfChapters: Int?
    var selectedBible: String?
    var delegate: MapTextViewControllerDelegate?
    var locations: [String : [String : [String]]]?
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    var lastAnnotation: MKAnnotation?
    var shouldToggle = false
    var currentLocations = [BibleLocation]()
    var shouldReloadMap = false
    
    let books = ["Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth","1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi","Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"]
    
    //Life Cycle Functions*********************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate.managedObjectContext
        
        let screenSize: CGRect = UIScreen.main.bounds
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = screenSize.height - y
        
        appDelegate.myMapView.delegate = self
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: height/2)
        appDelegate.myMapView.mapType = MKMapType.standard
        view.addSubview(appDelegate.myMapView)
        myTextView.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        aiv.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.view.addGestureRecognizer(gesture)
        
        //Set Bible Translation
        selectedBible = UserDefaults.standard.value(forKey: "selectedBible") as? String
        if selectedBible == "King James Version" {
            locations = BibleLocationsKJV.Locations
        }
        
        if let location = defaults.dictionary(forKey: "\(book) location") {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location["lat"] as! Double, location["long"] as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(location["latDelta"] as! Double, location["longDelta"] as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(center, span)
            appDelegate.myMapView?.setRegion(region, animated: true)
            appDelegate.myMapView?.setCenter(center, animated: false)
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
            appDelegate.myMapView?.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        }
        
        myTextView.delegate = self
        
        menuButton.image = resizeImage(image: UIImage(named:"Menu")!)
        
        //Set look of screen
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        //Set starting chapter
        if let chapter = defaults.value(forKey: book!) {
            chapterIndex = chapter as? Int
        } else {
            chapterIndex = 1
        }
        
        reloadMapTextView(book: book!, chapterIndex: chapterIndex!, shouldToggle: false, shouldReloadMap: shouldReloadMap)
        shouldReloadMap = false
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //Configure swipes
        let swipeLeft = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.left)
        swipeLeft.addTarget(self, action: #selector(MapTextViewController.swipeLeft))

        let swipeRight = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.right)
        swipeRight.addTarget(self, action: #selector(MapTextViewController.swipeRight))
        
        chapterTitles = getChapterTitlesFor(book: book!)
        
        self.navItem.title = "\(book!) \(String(describing: chapterIndex!))"
        
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        if appDelegate.currentState == .LeftPanelExpanded {
            delegate?.toggleLeftPanel!()
        } else if appDelegate.currentState == .RightPanelExpanded {
            delegate?.toggleRightPanel!()
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(bibleLocations![0].lat,bibleLocations![0].long)
            appDelegate.myMapView?.setCenter(center, animated: false)
        } else {
            return
        }
    }

    func resizeImage(image: UIImage) -> UIImage {
        let newWidth = image.size.width/1.75
        let newHeight = image.size.height/1.75
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getChapterTitlesFor(book: String) -> [String] {
        var chapterTitles: [String] = []
        numberOfChapters = Books.booksDictionary[book]
        for i in 1...numberOfChapters! {
            chapterTitles.append("\(book) \(String(i))")
        }
        return chapterTitles
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myTextView.isScrollEnabled = true
        myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        let defaults = UserDefaults.standard
        defaults.set(chapterIndex, forKey: book!)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myTextView.isScrollEnabled = false
        myTextView.isEditable = false
        
        getCurrentBook()
        getPinsForBook()
        addSavedPinsToMap()
        
    }
    
    //Text View********************************************************************************

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if appDelegate.currentState == .RightPanelExpanded {
            return false
        }
        
        let decodedURL = URL.absoluteString.replacingOccurrences(of: "%20", with: " ")
        
        for location in currentLocations {
            if decodedURL == location.key {
                setUpMap(name: location.name!, lat: location.lat, long: location.long)
                
                let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
                newPin.lat = location.lat
                newPin.long = location.long
                newPin.title = location.name!
                newPin.pinToBook = currentBook
                pinsForBook.append(newPin)
                
                appDelegate.saveContext()
                
                return true
            }
        }
        return false
    }
    
    //IBActions********************************************************************************

    @IBAction func menuButtonPressed(_ sender: Any) {
        appDelegate.chapterIndex = chapterIndex!
        delegate?.toggleLeftPanel?()
    }
    
    //Map View*********************************************************************************
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        tappedLocation = (view.annotation?.title!)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BibleLocation")
        
        let p = NSPredicate(format: "name = %@", tappedLocation)
        fetchRequest.predicate = p
        
        do {
            let results = try context!.fetch(fetchRequest)
            bibleLocations = results as! [BibleLocation]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        var titles: [String] = []
        for i in 0...(bibleLocations?.count)! - 1 {
            titles.append((bibleLocations?[i].key)!)
        }
        
        chapterAppearances = [[String]](repeating: [], count: 66)
        subtitles = [[String]](repeating: [], count: 66)
        bookAppearances = []
        
        for book in books {
            for i in 1...Books.booksDictionary[book]! {
                let bookDict = locations?[book]!
                let chapterArray = bookDict?[String(i)]!
                for title in titles as! [String] {
                    if (chapterArray?.contains(title))! {
                        if !chapterAppearances[books.index(of: book)!].contains("\(book) \(i)") {
                            chapterAppearances[books.index(of: book)!].append("\(book) \(i)")
                            subtitles[books.index(of: book)!].append(title)
                        }
                    }
                }
            }
        }
        
        var i = 0
        var j = 0
        for book in chapterAppearances {
            if book.count == 0 {
                chapterAppearances.remove(at: i)
                subtitles.remove(at: i)
            } else {
                i += 1
                bookAppearances.append(books[j])
            }
            j += 1
        }
        
        if appDelegate.currentState == .LeftPanelExpanded {
            delegate?.toggleLeftPanel!()
        }
        delegate?.toggleRightPanel?()
        
        
        let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(bibleLocations![0].lat,bibleLocations![0].long  - currentLongDelta/4)
        appDelegate.myMapView?.setCenter(center, animated: false)
        
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

        if !shouldAddAnnotation {
            appDelegate.myMapView.removeAnnotation(alreadyAddedAnnotation!)
        }

        let annotation = MKPointAnnotation()

        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = name
        appDelegate.myMapView.addAnnotation(annotation)
        appDelegate.myMapView.selectAnnotation(annotation, animated: false)
        lastAnnotation = annotation
        
    }
    
    func swipeLeft() {
        let prefix = "AJZ.WalkThroughTheBible."
        let currentIndex = books.index(of: book!)
        if chapterIndex != numberOfChapters {
            chapterIndex! += 1
            swipeActions()
            return
        } else if book == "Genesis" {
            if defaults.bool(forKey:"\(prefix)Exodus") {
                book = "Exodus"
            } else {
                return
            }
        } else if book == "Leviticus" {
            if defaults.bool(forKey:"\(prefix)Numbers") {
                book = "Numbers"
            } else {
                return
            }
        } else if book == "John" {
            if defaults.bool(forKey:"\(prefix)Acts") {
                book = "Acts"
            } else {
                return
            }
        } else {
            if book == "Revelation" {
                book = "Genesis"
            } else {
                book = books[currentIndex!+1]
            }
        }
        shouldReloadMap = true
        completeRawText = nil
        numberOfChapters = Books.booksDictionary[book!]
        chapterIndex = 1
        swipeActions()
    }

    func swipeRight() {
        let prefix = "AJZ.WalkThroughTheBible."
        let currentIndex = books.index(of: book!)
        if chapterIndex != 1 {
            chapterIndex! -= 1
            swipeActions()
            return
        } else if book == "Leviticus" {
            if defaults.bool(forKey:"\(prefix)Exodus") {
                book = "Exodus"
            } else {
                return
            }
        } else if book == "Deuteronomy" {
            if defaults.bool(forKey:"\(prefix)Numbers") {
                book = "Numbers"
            } else {
                return
            }
        } else if book == "Romans" {
            if defaults.bool(forKey:"\(prefix)Acts") {
                book = "Acts"
            } else {
                return
            }
        } else {
            if book == "Genesis" {
                book = "Revelation"
            } else {
                book = books[currentIndex!-1]
            }
        }
        shouldReloadMap = true
        completeRawText = nil
        numberOfChapters = Books.booksDictionary[book!]
        chapterIndex = Books.booksDictionary[book!]
        swipeActions()
    }
    
    func swipeActions() {
        reloadMapTextView(book: book!, chapterIndex: chapterIndex!, shouldToggle: false, shouldReloadMap: shouldReloadMap)
        shouldReloadMap = false
    }
    
    func addSwipeFunction(direction: UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        self.view.addGestureRecognizer(swipe)
        return swipe
    }
    
    func booksButtonPressed() {
        if appDelegate.currentState == .RightPanelExpanded {
            delegate?.toggleRightPanel!()
        }
        delegate?.toggleLeftPanel?()
        dismiss(animated: true, completion: nil)
    }
    
    func getCurrentBook() {

        let request: NSFetchRequest<Book> = Book.fetchRequest()

        do {
            let results = try context!.fetch(request as! NSFetchRequest<NSFetchRequestResult>)

            for book in results as! [Book] {
                if book.name == self.book! {
                    currentBook = book
                    return
                }
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context!) as! Book
        newBook.name = book
        currentBook = newBook
        return

    }

    func getPinsForBook() {

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
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}

extension MapTextViewController: SidePanelViewControllerDelegate {
    //Helper Functions*************************************************************************
    
    func reloadMapTextView(book: String, chapterIndex: Int, shouldToggle: Bool, shouldReloadMap: Bool) {
        self.book = book
        chapterTitles = getChapterTitlesFor(book: book)
        self.chapterIndex = chapterIndex
        aiv.isHidden = false
        aiv.startAnimating()
        myTextView.text = ""
        DispatchQueue.main.async {
            self.setUpText(book: book, chapterIndex: chapterIndex, shouldToggle: shouldToggle)
            self.aiv.stopAnimating()
            self.aiv.isHidden = true
        }
        if shouldReloadMap {
            appDelegate.myMapView.removeAnnotations(appDelegate.myMapView.annotations)
            getCurrentBook()
            getPinsForBook()
            addSavedPinsToMap()
        }
    }

    func setUpText(book: String, chapterIndex: Int, shouldToggle: Bool) {
        
        var verseNumbers = ["\(chapterIndex):1"]
        if verseNumbers.count == 1 {
            for i in 2...176 {
                verseNumbers.append("\(chapterIndex):\(i)")
            }
        }
        
        let path = Bundle.main.path(forResource: book, ofType: "txt", inDirectory: "KingJamesVersion")
        
        if completeRawText != nil && appDelegate.currentState != .RightPanelExpanded {
            print("Text has already been retrieved")
        } else {
            do {
                completeRawText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            } catch {
                print("Contents of File could not be retrieved")
            }
        }
        
        let totalChars = completeRawText?.characters.count
        
        if let theRange = completeRawText?.range(of: completeRawText!) {
            
            let startString = "\(chapterIndex):1"
            let endString = "\(chapterIndex+1):1"
            let startRange = (completeRawText! as NSString).range(of: startString)
            let endRange = (completeRawText! as NSString).range(of: endString)
            let low = completeRawText?.index(theRange.lowerBound, offsetBy: startRange.location)
            
            if endRange.location > totalChars! {
                rawText = completeRawText?.substring(from: low!)
            } else {
                let high = completeRawText?.index(theRange.lowerBound, offsetBy: endRange.location)
                let subRange = low! ..< high!
                rawText = completeRawText?[subRange]
            }
        }
        
        rawText = rawText?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        attributedText = NSMutableAttributedString(string: rawText! as String)
        let allTextRange = (rawText! as NSString).range(of: rawText!)
        
        attributedText?.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Light", size:16.0)!, range: allTextRange)

        let places = locations?[book]?[String(describing: chapterIndex)]!
        
        currentLocations = []

        if (places?.count)! > 0 {
            for place in places! {
                
                for location in appDelegate.glossary {
                    if place == location.key {
                        currentLocations.append(location)
                        continue
                    }
                }

                var range = (rawText! as NSString).range(of: place)
                var offset = 0
                let totalCharacters = rawText?.characters.count

                while range.location < totalChars! {

                    let value = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                    attributedText?.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                    attributedText?.addAttribute(NSLinkAttributeName, value: value!, range: range)

                    offset = range.location + 1
                    let startIndex = rawText?.index((rawText?.startIndex)!, offsetBy: offset)
                    let newText = rawText?.substring(from: startIndex!)

                    range = (newText! as NSString).range(of: place)

                    if range.location < totalChars! {
                        if offset + range.location < totalCharacters! {
                            range = NSMakeRange(offset + range.location, range.length)
                        }
                    }
                }
            }
        }
        
        var charactersRemoved = 0
        var replacementString = ""
        for verse in verseNumbers {
            let range = (rawText! as NSString).range(of: verse)
            
            let a = String(describing: chapterIndex).characters.count + 1
            
            if range.location < totalChars! {
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
                attributedText?.replaceCharacters(in: toDelete, with: replacementString)
                attributedText?.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:12.0)!, range: newRange)
            }
            charactersRemoved = charactersRemoved + a - replacementString.characters.count
        }
        
        myTextView.attributedText = attributedText
        myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        self.navItem.title = "\(book) \(String(describing: chapterIndex))"
        
        if shouldToggle {
            if appDelegate.currentState == .LeftPanelExpanded {
                delegate?.toggleLeftPanel?()
            } else {
                delegate?.toggleRightPanel?()
                let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(bibleLocations![0].lat,bibleLocations![0].long)
                appDelegate.myMapView?.setCenter(center, animated: false)
            }
        }

    }

}

