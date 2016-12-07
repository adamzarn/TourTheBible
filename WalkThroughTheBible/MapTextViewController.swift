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
    
    var chapterTitles: [String] = []
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
        
        loadText(chapterIndex: chapterIndex!, shouldToggle: false)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //Configure swipes
        let swipeLeft = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.left)
        swipeLeft.addTarget(self, action: #selector(MapTextViewController.swipeLeft))

        let swipeRight = addSwipeFunction(direction: UISwipeGestureRecognizerDirection.right)
        swipeRight.addTarget(self, action: #selector(MapTextViewController.swipeRight))
        
        chapterTitles = getChapterTitlesFor(book: book!)
        
        self.navItem.title = "\(book!) \(String(describing: chapterIndex!))"
        
    }
    
    deinit {
        print("MapTextViewController destroyed.")
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
        
        URLCache.shared.removeAllCachedResponses()
    
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
        if chapterIndex != numberOfChapters { chapterIndex! += 1 } else { return }
        swipeActions()
    }

    func swipeRight() {
        if chapterIndex != 1 { chapterIndex! -= 1 } else { return }
        swipeActions()
    }
    
    func swipeActions() {
        loadText(chapterIndex: chapterIndex!, shouldToggle: false)
    }
    
    func addSwipeFunction(direction: UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        self.view.addGestureRecognizer(swipe)
        return swipe
    }
    
    func booksButtonPressed() {
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
    
    func loadText(chapterIndex: Int, shouldToggle: Bool) {
        self.chapterIndex = chapterIndex
        aiv.isHidden = false
        aiv.startAnimating()
        myTextView.text = ""
        DispatchQueue.main.async {
            self.setUpText(chapterIndex: chapterIndex, shouldToggle: shouldToggle)
            self.aiv.stopAnimating()
            self.aiv.isHidden = true
        }
        
    }

    func setUpText(chapterIndex: Int, shouldToggle: Bool) {
        
        var verseNumbers = ["\(chapterIndex):1"]
        if verseNumbers.count == 1 {
            for i in 2...100 {
                verseNumbers.append("\(chapterIndex):\(i)")
            }
        }
        
        let path = Bundle.main.path(forResource: book!, ofType: "txt", inDirectory: "KingJamesVersion")
        
        if completeRawText != nil {
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

        let places = locations?[book!]?[String(describing: chapterIndex)]!
        
        currentLocations = []
        
        //var keys = [] as [String]
        //for places in glossary {

        if (places?.count)! > 0 {
            for place in places! {
            //for (key, _) in places {
                
                for location in appDelegate.glossary {
                    if place == location.key {
                        currentLocations.append(location)
                        continue
                    }
                }
                
                //var range = (rawText as NSString).range(of: key as String)
                var range = (rawText! as NSString).range(of: place)
                var offset = 0
                let totalCharacters = rawText?.characters.count

                while range.location < totalChars! {
                    //if !keys.contains(key) {
                    //    keys.append(key)
                    //}
                    //let value = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let value = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                    attributedText?.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                    attributedText?.addAttribute(NSLinkAttributeName, value: value!, range: range)

                    offset = range.location + 1
                    let startIndex = rawText?.index((rawText?.startIndex)!, offsetBy: offset)
                    let newText = rawText?.substring(from: startIndex!)

                    //range = (newText as NSString).range(of: key)
                    range = (newText! as NSString).range(of: place)

                    if range.location < totalChars! {
                        if offset + range.location < totalCharacters! {
                            range = NSMakeRange(offset + range.location, range.length)
                        }
                    }
                }
            }
        }
        //}
        
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
        self.navItem.title = "\(book!) \(String(describing: chapterIndex))"
        
        if shouldToggle {
            delegate?.toggleLeftPanel?()
        }

    }

}

