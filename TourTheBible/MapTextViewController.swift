//
//  MapTextViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 11/30/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import youtube_ios_player_helper

@objc
protocol MapTextViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
}

class MapTextViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate, YTPlayerViewDelegate {
    
    //IBOutlets********************************************************************************
    
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var fetchingAppearancesView: UIView!
    @IBOutlet weak var fetchingAppearancesLabel: UILabel!
    @IBOutlet weak var fetchingAppearancesAiv: UIActivityIndicatorView!
    
    //Controller Variables*********************************************************************
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var viewInYouTubeButton: UIButton!
    @IBOutlet weak var viewYouTubeChannelButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var bibleLocations: [BibleLocation]?
    var selectedLocations: [BibleLocation] = []
    var videosForBook: [Video]?
    var tappedLocation: String = ""
    var chapterTitles: [String] = []
    var chapterAppearances: [[Chapter]] = []
    var completeRawText: String?
    var rawText: String?
    var totalChars: Int?
    var attributedText: NSMutableAttributedString?
    var chapterIndex: Int? {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(chapterIndex, forKey: book!)
        }
    }
    var book: String?
    var numberOfChapters: Int?
    var selectedBible: String?
    var delegate: MapTextViewControllerDelegate?
    var locations: [String : [String : [String]]]?
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    var lastAnnotation: MKAnnotation?
    var shouldToggle = false
    var currentLocations: [String] = []
    var shouldReloadMap = false
    var currentVideoID: String?
    var screenSize: CGRect!
    var gesture: UITapGestureRecognizer?
    var dimView: UIView!
    
    var tappedBibleLocation: BibleLocation?
    
    let books = Books.books
    
    //Life Cycle Functions*********************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        screenSize = self.view.bounds
        
        dimView = UIView(frame: self.view.bounds)
        dimView.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        
        context = appDelegate.managedObjectContext
        
        let YTColor = UIColor(red: 179/255, green: 18/255, blue: 23/255, alpha: 1.0)
        
        appDelegate.myYouTubePlayer.delegate = self
        view.addSubview(appDelegate.myYouTubePlayer)
        appDelegate.myYouTubePlayer.isHidden = true
        
        appDelegate.myMapView.delegate = self
        appDelegate.myMapView.mapType = MKMapType.standard
        appDelegate.myMapView.isHidden = false
        view.addSubview(appDelegate.myMapView)
        
        viewInYouTubeButton.backgroundColor = YTColor
        viewInYouTubeButton.isHidden = true
        viewInYouTubeButton.setTitle("View in YouTube", for: .normal)
        viewInYouTubeButton.setTitleColor(UIColor.white, for: .normal)
        viewInYouTubeButton.layer.cornerRadius = 5
        
        viewYouTubeChannelButton.backgroundColor = YTColor
        viewYouTubeChannelButton.isHidden = true
        viewYouTubeChannelButton.setTitle("YouTube Channel", for: .normal)
        viewYouTubeChannelButton.setTitleColor(UIColor.white, for: .normal)
        viewYouTubeChannelButton.layer.cornerRadius = 5
        
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = true
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture?.isEnabled = false
        self.view.addGestureRecognizer(gesture!)
        
        if let location = defaults.dictionary(forKey: "\(book) location") {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location["lat"] as! Double, location["long"] as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(location["latDelta"] as! Double, location["longDelta"] as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(center, span)
            appDelegate.myMapView?.setRegion(region, animated: true)
            appDelegate.myMapView?.setCenter(center, animated: true)
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
            appDelegate.myMapView?.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        }
        
        myTextView.delegate = self
        
        menuButton.image = resizeImage(image: UIImage(named:"Menu")!)
        menuButton.tintColor = .white
        mapButton.image = resizeImage(image: UIImage(named:"Map")!)
        mapButton.tintColor = .white
        mapButton.isEnabled = false
        
        //Set look of screen
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        //Set starting chapter
        let bookmark = defaults.value(forKey: book!)
        if bookmark != nil {
            chapterIndex = bookmark as? Int
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
        
        mapTypeButton.setTitle(" Satellite ", for: .normal)
        mapTypeButton.layer.borderWidth = 1
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.view.bringSubview(toFront: mapTypeButton)
        
        fetchingAppearancesView.isHidden = true
        fetchingAppearancesView.layer.cornerRadius = 10;
        fetchingAppearancesView.isUserInteractionEnabled = false
        
        adjustSubviews()
        
    }
    
    func setUpTitleView(book: String, chapterIndex: Int) {
        
        let titleView = UIView()
        let title = UILabel()
        title.textColor = .white
        let subtitle = UILabel()
        subtitle.textColor = .white
        
        let width = self.navigationController?.navigationBar.frame.width
        let height = self.navigationController?.navigationBar.frame.height
        let middle = width!/2
        let titleViewWidth = CGFloat(200.0)
        let titleViewX = middle - titleViewWidth/2
        
        titleView.frame = CGRect(x: titleViewX, y: 0.0, width: titleViewWidth, height: height!)
        
        title.frame = CGRect(x: 0.0, y: -5.0, width: titleViewWidth, height: height!)
        title.text = "\(book) \(String(describing: chapterIndex))"
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        title.font = UIFont(name: "Papyrus", size: 20.0)
        title.minimumScaleFactor = 0.5
        
        subtitle.frame = CGRect(x: 0.0, y: height!/2, width: titleViewWidth, height: height!/2)
        subtitle.text = selectedBible
        subtitle.textAlignment = .center
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.font = UIFont(name: "Papyrus", size: 10.0)
        subtitle.minimumScaleFactor = 0.5
        
        titleView.addSubview(title)
        titleView.addSubview(subtitle)
        
        self.navItem.titleView = titleView
    }
    
//    func frame(buttonItem: UIBarButtonItem) -> CGRect {
//        if let view = (buttonItem.value(forKey: "view") as? UIView) {
//            return view!.frame
//        } else {
//            return CGRect(
//        }
//    }
    
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
        let y = CGFloat(0.0)
        let height = screenSize.height - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.height
        let YTPlayerHeight = (screenSize.width/16)*9
        appDelegate.myYouTubePlayer.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: YTPlayerHeight)
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: height * 0.45)
        myTextView.frame = CGRect(x: 0.0, y: y + (height * 0.45), width: screenSize.width, height: height * 0.55)
        viewInYouTubeButton.frame = CGRect(x: 5.0, y: y + YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height * 0.45) - YTPlayerHeight - 10.0)
        viewYouTubeChannelButton.frame = CGRect(x: (screenSize.width/2) + 2.5, y: y + YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height * 0.45) - YTPlayerHeight - 10.0)
        loadingLabel.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: YTPlayerHeight)
        aiv.frame = CGRect(x: 0.0, y: y + height/2, width: screenSize.width, height: height/2)
        
        let w = screenSize.width - 80.0
        fetchingAppearancesView.frame = CGRect(x: 40.0, y: (height/2) - 40.0, width: w, height: 80.0)
        fetchingAppearancesAiv.frame = CGRect(x:0.0, y: 10.0, width: w, height: 30.0)
        fetchingAppearancesLabel.frame = CGRect(x: 10.0, y: 40.0, width: w - 20.0, height: 30.0)
        
        self.view.bringSubview(toFront: mapTypeButton)
    }
    
    @IBAction func dismissYouTube(_ sender: Any) {
        showMap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        if appDelegate.currentState == .LeftPanelExpanded {
            delegate?.toggleLeftPanel!()
            let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
            let lat = appDelegate.myMapView.centerCoordinate.latitude
            let long = appDelegate.myMapView.centerCoordinate.longitude
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long - currentLongDelta/4)
            appDelegate.myMapView?.setCenter(center, animated: true)
        } else if appDelegate.currentState == .RightPanelExpanded {
            delegate?.toggleRightPanel!()
            self.setTappedBibleLocation(locationName: self.tappedLocation)
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(tappedBibleLocation!.lat,tappedBibleLocation!.long)
            appDelegate.myMapView?.setCenter(center, animated: true)
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
        if appDelegate.myMapView.mapType == MKMapType.standard {
            mapTypeButton.setTitle(" Satellite ", for: .normal)
        } else {
            mapTypeButton.setTitle(" Standard ", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadingLabel.isHidden = true
        gesture?.isEnabled = false
        
        myTextView.isScrollEnabled = false
        myTextView.isEditable = false
        
        getCurrentBook()
        getPinsForBook()
        addSavedPinsToMap()
        
    }
    
    //Text View********************************************************************************
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        var prefix = ""
        var videoID = ""
        
        if appDelegate.currentState == .RightPanelExpanded {
            return false
        }
        
        let URLstring = URL.absoluteString
        if URLstring.characters.count > 7 {
            let substring = URLstring.startIndex..<URLstring.index(URLstring.startIndex,offsetBy:7)
            prefix = URLstring[substring]
        }
        
        if prefix == "videoID" {
            let videoIDRange = URLstring.index(URLstring.startIndex,offsetBy:7)..<URLstring.endIndex
            videoID = URLstring[videoIDRange]
        }
        
        if appDelegate.myYouTubePlayer.playerState() == YTPlayerState.playing && prefix == "videoID" && currentVideoID == videoID {
            return false
        }
        
        if prefix != "videoID" {
            showMap()
            let decodedURL = URL.absoluteString.replacingOccurrences(of: "%20", with: " ")
            
            AWSClient.sharedInstance.getBibleLocation(name: decodedURL, completion: { (bibleLocation, error) -> () in
                if let location = bibleLocation {
                    
                    self.plotPin(loc: location)
                    
                    let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: self.context!) as! Pin
                    newPin.lat = location.lat
                    newPin.long = location.long
                    newPin.title = location.displayName
                    newPin.subtitle = location.name
                    newPin.pinToBook = self.currentBook
                    self.pinsForBook.append(newPin)
                    
                    self.appDelegate.saveContext()
                
                } else {
                    print("error")
                }
            })
        
        } else {
            showYouTube(videoID: videoID)
            return true
        }
        return true
    }
    
    func showMap() {
        mapTypeButton.isEnabled = true
        mapTypeButton.isHidden = false
        clearMapButton.isEnabled = true
        mapButton.isEnabled = false
        loadingLabel.isHidden = true
        appDelegate.myYouTubePlayer.isHidden = true
        appDelegate.myYouTubePlayer.stopVideo()
        view.sendSubview(toBack: appDelegate.myYouTubePlayer)
        viewInYouTubeButton.isHidden = true
        viewInYouTubeButton.isEnabled = false
        viewYouTubeChannelButton.isHidden = true
        viewYouTubeChannelButton.isEnabled = false
        appDelegate.myMapView.isHidden = false
    }
    
    func showYouTube(videoID: String) {
        mapTypeButton.isEnabled = false
        mapTypeButton.isHidden = true
        clearMapButton.isEnabled = false
        mapButton.isEnabled = true
        appDelegate.myMapView.isHidden = true
        loadingLabel.isHidden = false
        view.bringSubview(toFront: loadingLabel)
        currentVideoID = videoID
        appDelegate.myYouTubePlayer.isHidden = false
        appDelegate.myYouTubePlayer.load(withVideoId: videoID, playerVars: ["playsinline": 1, "rel": 0])
        viewInYouTubeButton.isHidden = false
        viewInYouTubeButton.isEnabled = true
        viewYouTubeChannelButton.isHidden = false
        viewYouTubeChannelButton.isEnabled = true
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        loadingLabel.isHidden = true
    }
    
    //IBActions********************************************************************************
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        appDelegate.chapterIndex = chapterIndex!
        delegate?.toggleLeftPanel?()
        let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
        let lat = appDelegate.myMapView.centerCoordinate.latitude
        let long = appDelegate.myMapView.centerCoordinate.longitude
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long + currentLongDelta/4)
        appDelegate.myMapView?.setCenter(center, animated: true)
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
        
        if appDelegate.currentState != .RightPanelExpanded && appDelegate.currentState != .LeftPanelExpanded {
            showFetchingAppearancesView()
            tappedLocation = (view.annotation?.title!)!
            var tappedLocationSubtitle = (view.annotation?.subtitle!)!
            self.setTappedBibleLocation(locationName: tappedLocationSubtitle)
            
            AWSClient.sharedInstance.getChapterAppearances(location: (tappedBibleLocation?.name)!, completion: { (chapterAppearances, error) -> () in
                self.dismissFetchingAppearancesView()
                if let chapterAppearances = chapterAppearances {
                    print(chapterAppearances)
                    self.chapterAppearances = chapterAppearances
                    self.delegate?.toggleRightPanel?()
                    let currentLongDelta = self.appDelegate.myMapView.region.span.longitudeDelta
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((self.tappedBibleLocation?.lat)!,(self.tappedBibleLocation?.long)!  - currentLongDelta/4)
                    self.appDelegate.myMapView?.setCenter(center, animated: true)
                    self.gesture?.isEnabled = true
                } else {
                    print("error")
                }
            })
            
        }
        
    }
    
    func showFetchingAppearancesView() {
        self.view.addSubview(dimView)
        self.view.bringSubview(toFront: dimView)
        fetchingAppearancesView.isHidden = false
        fetchingAppearancesView.isUserInteractionEnabled = true
        self.view.bringSubview(toFront: fetchingAppearancesView)
        fetchingAppearancesAiv.startAnimating()
    }
    
    func dismissFetchingAppearancesView() {
        self.dimView.removeFromSuperview()
        fetchingAppearancesView.isHidden = true
        fetchingAppearancesView.isUserInteractionEnabled = false
        fetchingAppearancesAiv.stopAnimating()
    }
    
    func setTappedBibleLocation(locationName: String) {
        print(locationName)
        print(" ")
        for loc in selectedLocations {
            print(loc.name, loc.displayName, loc.lat, loc.long)
            print(loc.name)
            if loc.name == locationName {
                tappedBibleLocation = loc
            }
        }
    }
    
    func plotPin(loc: BibleLocation) {
        
        let coordinate = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.long)
        appDelegate.myMapView.setCenter(coordinate, animated: true)
        
        let allAnnotations = appDelegate.myMapView.annotations
        var shouldAddAnnotation = true
        var alreadyAddedAnnotation: MKAnnotation?
        
        for annotation in allAnnotations {
            if annotation.coordinate.latitude == loc.lat && annotation.coordinate.longitude == loc.long {
                shouldAddAnnotation = false
                alreadyAddedAnnotation = annotation
            }
        }
        
        if !shouldAddAnnotation {
            appDelegate.myMapView.removeAnnotation(alreadyAddedAnnotation!)
        }
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.long)
        annotation.title = loc.displayName
        annotation.subtitle = loc.name
        appDelegate.myMapView.addAnnotation(annotation)
        appDelegate.myMapView.selectAnnotation(annotation, animated: false)
        lastAnnotation = annotation
        selectedLocations.append(loc)
        
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
        appDelegate.myYouTubePlayer.stopVideo()
        if appDelegate.currentState == .RightPanelExpanded {
            delegate?.toggleRightPanel!()
        }
        delegate?.toggleLeftPanel?()
        dismiss(animated: true, completion: nil)
        appDelegate.tbc?.selectedIndex = 0
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
            annotation.subtitle = pin.subtitle
            appDelegate.myMapView.addAnnotation(annotation)
            let newLoc = BibleLocation(name: pin.subtitle!, displayName: pin.title! , lat: pin.lat, long: pin.long)
            selectedLocations.append(newLoc)
            
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
    
    @IBAction func viewInYouTubeButtonPressed(_ sender: Any) {
        appDelegate.myYouTubePlayer.stopVideo()
        var url = URL(string:"youtube://\(currentVideoID!)")!
        if UIApplication.shared.canOpenURL(url)  {
            UIApplication.shared.openURL(url)
        } else {
            url = URL(string:"http://www.youtube.com/watch?v=\(currentVideoID!)")!
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func viewYouTubeChannelPressed(_ sender: Any) {
        appDelegate.myYouTubePlayer.stopVideo()
        let youtubeId = "UC-tRUM6a6xf5paW6Ns9yd0w"
        var url = URL(string:"youtube://www.youtube.com/channel/\(youtubeId)")!
        if UIApplication.shared.canOpenURL(url)  {
            UIApplication.shared.openURL(url)
        } else {
            url = URL(string:"http://www.youtube.com/channel/\(youtubeId)")!
            UIApplication.shared.openURL(url)
        }
    }
    
}

extension MapTextViewController: SidePanelViewControllerDelegate {
    //Helper Functions*************************************************************************
    
    func reloadMapTextView(book: String, chapterIndex: Int, shouldToggle: Bool, shouldReloadMap: Bool) {
        
        //Set Bible Translation
        selectedBible = defaults.value(forKey: "selectedBible") as? String
        
        self.showMap()
        self.book = book
        chapterTitles = getChapterTitlesFor(book: book)
        self.chapterIndex = chapterIndex
        aiv.isHidden = false
        aiv.startAnimating()
        myTextView.text = ""
        DispatchQueue.main.async {
            self.setUpText(book: book, chapterIndex: chapterIndex, shouldToggle: shouldToggle)
        }
        if shouldReloadMap {
            appDelegate.myMapView.removeAnnotations(appDelegate.myMapView.annotations)
            getCurrentBook()
            getPinsForBook()
            addSavedPinsToMap()
        }
        
        appDelegate.lastBook = book
        appDelegate.lastChapter = chapterIndex
        setUpTitleView(book: book, chapterIndex: chapterIndex)
        
    }
    
    func setUpVerseArray() -> [String] {
        var verseNumbers = ["\(chapterIndex!):1"]
        if verseNumbers.count == 1 {
            for i in 2...176 {
                verseNumbers.append("\(chapterIndex!):\(i)")
            }
        }
        return verseNumbers
    }
    
    func getCompleteRawText() {
        
        let directory = selectedBible?.replacingOccurrences(of: " ", with: "")
        let path = Bundle.main.path(forResource: book, ofType: "txt", inDirectory: directory)
        
        do {
            completeRawText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            print("Text Retrieved")
        } catch {
            print("Contents of File could not be retrieved")
        }
    }
    
    func formatCompleteRawText() {
        self.totalChars = completeRawText?.characters.count
        if let theRange = completeRawText?.range(of: completeRawText!) {
            let startString = "\(chapterIndex!):1"
            let endString = "\(chapterIndex!+1):1"
            let startRange = (completeRawText! as NSString).range(of: startString)
            let endRange = (completeRawText! as NSString).range(of: endString)
            let low = completeRawText?.index(theRange.lowerBound, offsetBy: startRange.location)
            
            if endRange.location > self.totalChars! {
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
    }
    
    func addVerseHyperlinks() {
        
        if videosForBook!.count > 0 {
            for video in videosForBook! {
                let value = video.videoID
                let verseComponents = video.verses.characters.split{$0 == ":"}.map(String.init)
                if verseComponents[0] == String(describing: chapterIndex!) {
                    if let theRange = rawText?.range(of: rawText!) {
                        let startString = "\(chapterIndex!):\(verseComponents[1])"
                        
                        let verseString = String(describing:Int(verseComponents[2])! + 1)
                        let endString = "\(chapterIndex!):\(verseString)"
                        
                        let startRange = (rawText! as NSString).range(of: startString)
                        let endRange = (rawText! as NSString).range(of: endString)
                        
                        let low = rawText?.index(theRange.lowerBound, offsetBy: startRange.location + verseComponents[0].characters.count + 1)
                        let high: String.Index!
                        var subRangeString: String!
                        
                        if endRange.location > self.totalChars! {
                            subRangeString = rawText?.substring(from: low!)
                        } else {
                            high = rawText?.index(theRange.lowerBound, offsetBy: endRange.location - 1)
                            let subRange = low! ..< high!
                            subRangeString = rawText?[subRange]
                        }
                        
                        let range = (rawText! as NSString).range(of: subRangeString!)
                        attributedText?.addAttributes([NSFontAttributeName: UIFont(name:"Helvetica-Light", size:16.0)!,
                                                       NSForegroundColorAttributeName: UIColor.green,
                                                       NSLinkAttributeName: "videoID\(value)"],
                                                      range: range)
                        
                    }
                }
            }
        }
    }
    
    func getChapterLocations() {
        let chapter = book! + " " + String(describing: chapterIndex!)
        AWSClient.sharedInstance.getChapterLocations(chapter: chapter, completion: { (chapterLocations, error) -> () in
            if let chapterLocations = chapterLocations {
                self.currentLocations = chapterLocations
                self.addLocationHyperlinks()
            } else {
                print(error)
                self.formatVerseNumbers(verseNumbers: self.setUpVerseArray())
            }
        })
    }
    
    func addLocationHyperlinks() {
        
        if currentLocations.count > 0 {
            for loc in currentLocations {
                var range = (rawText! as NSString).range(of: loc)
                var offset = 0
                let totalCharacters = rawText?.characters.count
                while range.location < self.totalChars! {
                    
                    let value = loc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    attributedText?.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                    attributedText?.addAttribute(NSLinkAttributeName, value: value!, range: range)
                    
                    offset = range.location + 1
                    let startIndex = rawText?.index((rawText?.startIndex)!, offsetBy: offset)
                    let newText = rawText?.substring(from: startIndex!)
                    
                    range = (newText! as NSString).range(of: loc)
                    
                    if range.location < self.totalChars! {
                        if offset + range.location < totalCharacters! {
                            range = NSMakeRange(offset + range.location, range.length)
                        }
                    }
                }
            }
        }
        formatVerseNumbers(verseNumbers: setUpVerseArray())
    }
    
    func formatVerseNumbers(verseNumbers: [String]) {
        var charactersRemoved = 0
        var replacementString = ""
        for verse in verseNumbers {
            let range = (rawText! as NSString).range(of: verse)
            let a = String(describing: chapterIndex!).characters.count + 1
            if range.location < self.totalChars! {
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
                attributedText?.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: newRange)
            }
            charactersRemoved = charactersRemoved + a - replacementString.characters.count
        }
        displayText()
    }
    
    func setUpText(book: String, chapterIndex: Int, shouldToggle: Bool) {
        
        if shouldToggle {
            if self.appDelegate.currentState == .LeftPanelExpanded {
                self.delegate?.toggleLeftPanel?()
                let currentCenter = appDelegate.myMapView.centerCoordinate
                let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
                let newLat = currentCenter.latitude
                let newLong = currentCenter.longitude - currentLongDelta/4
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLat, newLong)
                appDelegate.myMapView.setCenter(center, animated: true)
            } else {
                self.delegate?.toggleRightPanel?()
                self.setTappedBibleLocation(locationName: self.tappedLocation)
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((tappedBibleLocation?.lat)!,(tappedBibleLocation?.long)!)
                self.appDelegate.myMapView?.setCenter(center, animated: true)
            }
        }
        
        self.getCompleteRawText()
        self.formatCompleteRawText()
        if FirebaseClient.sharedInstance.hasConnectivity() {
            FirebaseClient.sharedInstance.getVideoIDs(book: book, completion: { (videos, error) -> () in
                if let videos = videos {
                    self.videosForBook = videos
                } else {
                    self.videosForBook = []
                }
                self.addVerseHyperlinks()
                self.getChapterLocations()
            })
        } else {
            displayText()
        }
    }
    
    func displayText() {
        self.myTextView.attributedText = self.attributedText
        self.myTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        self.setUpTitleView(book: book!, chapterIndex: chapterIndex!)
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
    }
    
    func displayAlert() {
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

