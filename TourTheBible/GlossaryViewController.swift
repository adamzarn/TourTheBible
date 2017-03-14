//
//  GlossaryViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 10/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData
import youtube_ios_player_helper

@objc
protocol GlossaryViewControllerDelegate {
    @objc optional func toggleRightPanel()
}

class GlossaryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, YTPlayerViewDelegate, RightPanelViewControllerDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var aiv: UIActivityIndicatorView!

    @IBOutlet weak var viewInYouTubeButton: UIButton!
    @IBOutlet weak var viewYouTubeChannelButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var nothingToDisplayLabel: UILabel!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    let searchController = UISearchController(searchResultsController: nil)
    var sortedGlossary = [[BibleLocation]](repeating: [], count: 26)
    var masterGlossary = [BibleLocation]()
    var filteredGlossary = [BibleLocation]()
    var masterSongList = [Video]()
    var filteredSongList = [Video]()
    let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let books = ["Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth","1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi","Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"]
    
    var screenSize: CGRect!
    var y: CGFloat?
    var height: CGFloat?
    var keyboardHeight: CGFloat?
    var selectedBible: String? = nil
    var pinsForBook = [Pin]()
    var currentBook: Book? = nil
    var currentVideoID: String?
    var YTPlayerHeight: CGFloat?
    var songBooks: [String] = []
    var delegate: GlossaryViewControllerDelegate?
    
    var locations: [String : [String : [String]]]?
    var bibleLocations: [BibleLocation]?
    var tappedLocation: String = ""
    var tappedLocationKey: String = ""
    var chapterAppearances = [[String]](repeating: [], count: 66)
    var subtitles = [[String]](repeating: [], count: 66)
    var bookAppearances: [String] = []
    var gesture: UITapGestureRecognizer?
    var whiteBackground: UIView?
    var chapSel = false

    override func viewDidLoad() {
        
        screenSize = self.view.bounds
        
        context = appDelegate.managedObjectContext
        masterGlossary = appDelegate.glossary
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        
        let YTColor = UIColor(red: 179/255, green: 18/255, blue: 23/255, alpha: 1.0)
        
        appDelegate.myYouTubePlayer.delegate = self
        view.addSubview(appDelegate.myYouTubePlayer)
        appDelegate.myYouTubePlayer.isHidden = true
        
        appDelegate.myMapView.delegate = self
        appDelegate.myMapView.mapType = MKMapType.standard
        appDelegate.myMapView.isHidden = false
        
        myTableView.delegate = self
        
        viewInYouTubeButton.backgroundColor = YTColor
        viewInYouTubeButton.isHidden = true
        viewInYouTubeButton.isEnabled = false
        viewInYouTubeButton.setTitle("View in YouTube", for: .normal)
        viewInYouTubeButton.setTitleColor(UIColor.white, for: .normal)
        viewInYouTubeButton.layer.cornerRadius = 5
        
        viewYouTubeChannelButton.backgroundColor = YTColor
        viewYouTubeChannelButton.isHidden = true
        viewYouTubeChannelButton.isEnabled = false
        viewYouTubeChannelButton.setTitle("YouTube Channel", for: .normal)
        viewYouTubeChannelButton.setTitleColor(UIColor.white, for: .normal)
        viewYouTubeChannelButton.layer.cornerRadius = 5
        
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = true
        
        nothingToDisplayLabel.text = "Nothing to Display"
        nothingToDisplayLabel.textAlignment = .center
        nothingToDisplayLabel.isHidden = true
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture?.isEnabled = false
        self.view.addGestureRecognizer(gesture!)
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.automaticallyAdjustsScrollViewInsets = false
        
        selectedBible = defaults.value(forKey: "selectedBible") as? String
        if selectedBible == "King James Version" {
            locations = BibleLocationsKJV.Locations
        }
        
        mapTypeButton.setTitle(" Satellite ", for: .normal)
        mapTypeButton.layer.borderWidth = 1
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.view.bringSubview(toFront: mapTypeButton)
        
        aiv.isHidden = true
        
        adjustSubviews()
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
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let h = appDelegate.tabBarHeight!
        height = screenSize.height - y! - h
        let YTPlayerHeight = (screenSize.width/16)*9
        appDelegate.myYouTubePlayer.frame = CGRect(x: 0.0, y: y, width: screenSize.width, height: YTPlayerHeight)
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: (height!+h)*0.45)
        segmentedControl.frame = CGRect(x: 5, y: y! + (height!+h)*0.45 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: y! + (height!+h)*0.45 + 40, width: screenSize.width, height: (height!+h)*0.55 - 40 - h)
        aiv.frame = CGRect(x: (screenSize.width/2) - 10, y: y! + (height!+h)*0.45 + 55, width: 20, height: 20)
        viewInYouTubeButton.frame = CGRect(x: 5.0, y: y! + YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height! + h)*0.45 - YTPlayerHeight - 10.0)
        viewYouTubeChannelButton.frame = CGRect(x: (screenSize.width/2) + 2.5, y: y! + YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height! + h)*0.45 - YTPlayerHeight - 10.0)
        loadingLabel.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: YTPlayerHeight)
        nothingToDisplayLabel.frame = CGRect(x: 0.0 , y: y! + (height!+h)*0.45 + 55, width: screenSize.width, height: 100)
        whiteBackground = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height))
        whiteBackground?.backgroundColor = .white
        view.addSubview(whiteBackground!)
        view.sendSubview(toBack: whiteBackground!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredGlossary = masterGlossary.filter { location in
                return (location.name?.lowercased().contains(searchText.lowercased()))!
            }
        } else {
            filteredSongList = masterSongList.filter { video in
                let vc = video.verses.characters.split{$0 == ":"}.map(String.init)
                if vc[1] == vc[2] {
                    return ("\(video.book) \(vc[0]):\(vc[1])".lowercased().contains(searchText.lowercased()))
                } else {
                    return ("\(video.book) \(vc[0]):\(vc[1])-\(vc[2])".lowercased().contains(searchText.lowercased()))
                }
            }
            filteredSongList.sort { ($0.bookSequence == $1.bookSequence) ? ($0.sequence < $1.sequence) : ($0.bookSequence < $1.bookSequence) }
        }
        myTableView.reloadData()
        myTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: true)
        appDelegate.myMapView.mapType = .standard
        
        gesture?.isEnabled = false
        
        if segmentedControl.selectedSegmentIndex == 1 {
            segmentedControl.isUserInteractionEnabled = false
        }
        
        loadingLabel.isHidden = true
        if !view.subviews.contains(appDelegate.myMapView) {
            view.addSubview(appDelegate.myMapView)
        }
        if !view.subviews.contains(appDelegate.myYouTubePlayer) {
            view.addSubview(appDelegate.myYouTubePlayer)
        }
        appDelegate.myMapView.isHidden = true
        appDelegate.myYouTubePlayer.isHidden = true
        
        if segmentedControl.selectedSegmentIndex == 0 {

            self.appDelegate.myMapView.removeAnnotations(self.appDelegate.myMapView.annotations)
            
            getCurrentBook()
            getPinsForGlossary()
            addSavedPinsToMap()
            
            for bibleLocation in masterGlossary {
                let name = bibleLocation.name!
                var i = 0
                for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
                    if name[name.startIndex] == char {
                        sortedGlossary[i].append(bibleLocation)
                    }
                    i += 1
                }
            }
        } else {
            appDelegate.myYouTubePlayer.delegate = self
        }
        
        appDelegate.myMapView.delegate = self
        appDelegate.myYouTubePlayer.delegate = self
        adjustSubviews()
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if segmentedControl.selectedSegmentIndex == 0 {
            myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            showMap()
        } else {
            if songBooks.count > 0 {
                myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            showYouTube(videoID: "HLE8Xjuqn2M")
        }
    }
    
    func getCurrentBook() {
        
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        do {
            let results = try context!.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            for book in results as! [Book] {
                if book.name == "Glossary" {
                    currentBook = book
                    return
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context!) as! Book
        newBook.name = "Glossary"
        currentBook = newBook
        return
        
    }
    
    func getPinsForGlossary() {
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        appDelegate.myYouTubePlayer.stopVideo()
        if appDelegate.glossaryState == .RightPanelExpanded && !chapSel {
            delegate?.toggleRightPanel!()
        }
        chapSel = false
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
            return nil
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            return letters
        }
        return songBooks
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return letters.index(of: title)!
        }
        return songBooks.index(of: title)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredGlossary.count
            }
            return sortedGlossary[section].count
        } else {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredSongList.count
            }
            return appDelegate.videoLibrary[songBooks[section]]!.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return 1
            }
            return sortedGlossary.count
        } else {
            if searchController.isActive && searchController.searchBar.text != "" {
                return 1
            }
            return songBooks.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            return letters[section]
        } else {
            return songBooks[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GlossaryCell
        if segmentedControl.selectedSegmentIndex == 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                cell.setUp(location: filteredGlossary[indexPath.row])
            } else {
                cell.setUp(location: sortedGlossary[indexPath.section][indexPath.row])
            }
            return cell
        } else {
            if searchController.isActive && searchController.searchBar.text != "" {
                cell.setUp(video: filteredSongList[indexPath.row])
            } else {
                let book = songBooks[indexPath.section]
                let videos = appDelegate.videoLibrary[book]
                cell.setUp(video: (videos?[indexPath.row])!)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        var video: Video!
        var book: String!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            video = filteredSongList[indexPath.row]
            book = video.book
        } else {
            book = songBooks[indexPath.section]
            let videos = appDelegate.videoLibrary[book]
            video = videos?[indexPath.row]
        }

        let vc = video?.verses.characters.split{$0 == ":"}.map(String.init)
        let chapterIndexString = vc?[0]
        let chapterIndex = Int(chapterIndexString!)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let goToScripture = UIAlertAction(title: "Go to \(book!) \(chapterIndex!)", style: .default) { (action) in
            let containerViewController = ContainerViewController()
            containerViewController.book = book
            containerViewController.chapterIndex = chapterIndex!
            self.present(containerViewController, animated: false, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
        alertController.addAction(cancelAction)
        alertController.addAction(goToScripture)
        
        self.present(alertController, animated: true, completion: nil)
        
        if searchController.isActive {
            searchBarCancelActions()
        }
    
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
        
        let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        segmentedControl.isHidden = false
        segmentedControl.isUserInteractionEnabled = true
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if searchController.isActive {
                var location: BibleLocation!
                if searchController.searchBar.text != "" {
                    location = filteredGlossary[indexPath.row] as BibleLocation
                } else {
                    location = sortedGlossary[indexPath.section][indexPath.row] as BibleLocation
                }
                setUpMap(name: location.name!, lat: location.lat, long: location.long)
                savePin(location: location!)
                y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
                tableView.frame = CGRect(x: 0.0, y: y! + height!*0.45 + 40, width: screenSize.width, height: height!*0.55 - 40)
                self.view.bringSubview(toFront: mapTypeButton)
                searchController.dismiss(animated: true, completion: nil)
                searchController.searchBar.text = ""
                
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.reloadData()
                
                let startingLetter = String(describing: location.name!.characters.first!).uppercased()
                let letterIndex = letters.index(of: startingLetter)
                let row = sortedGlossary[letterIndex!].index(of: location)
                let ip = IndexPath(row: row!, section: letterIndex!)
                
                tableView.scrollToRow(at: ip as IndexPath, at: .top, animated: false)
                
            } else {
                let location = sortedGlossary[indexPath.section][indexPath.row] as BibleLocation
                setUpMap(name: location.name!, lat: location.lat, long: location.long)
                savePin(location: location)
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        } else {
            searchController.searchBar.placeholder = "Please wait..."
            searchController.searchBar.isUserInteractionEnabled = false
            segmentedControl.isUserInteractionEnabled = false
            var video: Video!
            if searchController.isActive {
                if searchController.searchBar.text != "" {
                    video = filteredSongList[indexPath.row]
                } else {
                    let book = songBooks[indexPath.section]
                    let videos = appDelegate.videoLibrary[book]
                    video = videos?[indexPath.row]
                }
                searchController.dismiss(animated: true, completion: nil)
                searchController.searchBar.text = ""
                tableView.deselectRow(at: indexPath, animated: true)
                
                let videoID = video.videoID
                loadingLabel.isHidden = false
                view.bringSubview(toFront: loadingLabel)
                showYouTube(videoID: videoID)
                
                let book = video.book
                let section = songBooks.index(of: book)
                var i = 0
                var row = 0
                for video2 in appDelegate.videoLibrary[book]! {
                    if video.verses == video2.verses {
                        row = i
                        break
                    }
                    i += 1
                }
                let ip = IndexPath(row: row, section: section!)
                
                tableView.scrollToRow(at: ip as IndexPath, at: .top, animated: false)
                
            } else {
                let book = songBooks[indexPath.section]
                let videos = appDelegate.videoLibrary[book]
                video = videos?[indexPath.row]
                
                let videoID = video.videoID
                loadingLabel.isHidden = false
                view.bringSubview(toFront: loadingLabel)
                showYouTube(videoID: videoID)
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)

            }

        }
        
    }
    
    func savePin(location: BibleLocation) {
        
        let newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context!) as! Pin
        newPin.setValue(location.lat, forKey: "lat")
        newPin.setValue(location.long, forKey: "long")
        newPin.setValue(location.name, forKey: "title")
        newPin.setValue(currentBook, forKey: "pinToBook")
        pinsForBook.append(newPin)

        appDelegate.saveContext()
        
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
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if segmentedControl.selectedSegmentIndex == 1 && !hasConnectivity() {
            return false
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelActions()
    }
    
    func searchBarCancelActions() {
        segmentedControl.isHidden = false
        segmentedControl.isUserInteractionEnabled = true
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let tabBarHeight = (tabBarController?.tabBar.frame.size.height)!
        height = screenSize.height - y! - tabBarHeight
        myTableView.frame = CGRect(x: 0.0, y: y! + height!*0.45 + 40, width: screenSize.width, height: height!*0.55 - 40)
        searchController.searchBar.text = ""
        adjustSubviews()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GlossaryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {

        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y! - getKeyboardHeight(notification: notification)
        viewInYouTubeButton.isHidden = true
        viewInYouTubeButton.isEnabled = false
        viewYouTubeChannelButton.isHidden = true
        viewYouTubeChannelButton.isEnabled = false
        appDelegate.myMapView.isHidden = true
        appDelegate.myYouTubePlayer.isHidden = true
        myTableView.frame = CGRect(x: 0.0, y: y!, width: screenSize.width, height: height!)
        segmentedControl.isHidden = true
        segmentedControl.isUserInteractionEnabled = false
        clearMapButton.isEnabled = false
        mapTypeButton.isEnabled = false
        mapTypeButton.isHidden = true
        myTableView.setContentOffset(CGPoint.zero, animated: false)

    }
    
    func keyboardWillHide(notification: NSNotification) {
        if segmentedControl.selectedSegmentIndex == 0 {
            mapTypeButton.isEnabled = true
            mapTypeButton.isHidden = false
            appDelegate.myMapView.isHidden = false
            clearMapButton.isEnabled = true
        } else {
            appDelegate.myYouTubePlayer.isHidden = false
            viewInYouTubeButton.isHidden = false
            viewInYouTubeButton.isEnabled = true
            viewYouTubeChannelButton.isHidden = false
            viewYouTubeChannelButton.isEnabled = true
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        
        nothingToDisplayLabel.isHidden = true
        myTableView.isHidden = true
        aiv.isHidden = false
        aiv.startAnimating()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            myTableView.reloadData()
            myTableView.isHidden = false
            aiv.isHidden = true
            aiv.stopAnimating()
            showMap()
            searchController.searchBar.isUserInteractionEnabled = true
        } else {
            if FirebaseClient.sharedInstance.hasConnectivity() {
                searchController.searchBar.placeholder = "Please wait..."
                searchController.searchBar.isUserInteractionEnabled = false
                segmentedControl.isUserInteractionEnabled = false
                if self.appDelegate.videoLibrary.count == 0 {
                    FirebaseClient.sharedInstance.getVideoLibrary(completion: { (videoLibrary, error) -> () in
                        if let videoLibrary = videoLibrary {
                            var songBooksUnsorted: [String] = []
                            for (key, _) in videoLibrary {
                                songBooksUnsorted.append(key)
                            }
                            var bookSequence = 0
                            for book in self.books {
                                if songBooksUnsorted.contains(book) {
                                    self.songBooks.append(book)
                                    let unsortedVideos = videoLibrary[book]
                                    var tempVideos: [Video] = []
                                    for video in unsortedVideos! {
                                        let vc = video.verses.characters.split{$0 == ":"}.map(String.init)
                                        let sequence = Int(vc[0])!*1000 + Int(vc[1])!
                                        let newVideo = Video(verses: video.verses, videoID: video.videoID, sequence: sequence, bookSequence: bookSequence, book: video.book)
                                        tempVideos.append(newVideo)
                                        self.masterSongList.append(newVideo)
                                    }
                                    let sortedVideos = tempVideos.sorted { $0.sequence < $1.sequence }
                                    self.appDelegate.videoLibrary[book] = sortedVideos
                                }
                                bookSequence += 1
                            }
                            self.myTableView.reloadData()
                            self.myTableView.isHidden = false
                            self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                            self.aiv.isHidden = true
                            self.aiv.stopAnimating()
                            if self.appDelegate.myYouTubePlayer.playerState() == YTPlayerState.queued {
                                self.searchController.searchBar.placeholder = "Search"
                                self.searchController.searchBar.isUserInteractionEnabled = true
                                self.segmentedControl.isUserInteractionEnabled = true
                            }
                        }
                    })
                } else {
                    myTableView.reloadData()
                    myTableView.isHidden = false
                    myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    aiv.isHidden = true
                    aiv.stopAnimating()
                }
                showYouTube(videoID: "HLE8Xjuqn2M")
            } else {
                showYouTube(videoID: "HLE8Xjuqn2M")
                appDelegate.myYouTubePlayer.isHidden = true
                loadingLabel.text = "No Internet Connection"
                nothingToDisplayLabel.isHidden = false
                aiv.isHidden = true
                aiv.stopAnimating()
            }
        }
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
    
    @IBAction func viewYouTubeChannelButtonPressed(_ sender: Any) {
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
    
    func showMap() {
        getCurrentBook()
        getPinsForGlossary()
        addSavedPinsToMap()
        mapTypeButton.isEnabled = true
        mapTypeButton.isHidden = false
        if appDelegate.myMapView.mapType == MKMapType.standard {
            mapTypeButton.setTitle(" Satellite ", for: .normal)
        } else {
            mapTypeButton.setTitle(" Standard ", for: .normal)
        }
        view.bringSubview(toFront: mapTypeButton)
        clearMapButton.isEnabled = true
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
        appDelegate.myMapView.isHidden = true
        loadingLabel.text = "Loading..."
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
        if appDelegate.videoLibrary.count > 0 {
            searchController.searchBar.placeholder = "Search"
            searchController.searchBar.isUserInteractionEnabled = true
            segmentedControl.isUserInteractionEnabled = true
        }
        appDelegate.myYouTubePlayer.isHidden = false
        view.bringSubview(toFront: appDelegate.myYouTubePlayer)
        loadingLabel.isHidden = true
    }
    
    func hasConnectivity() -> Bool {
        do {
            let reachability = Reachability()
            let networkStatus: Int = reachability!.currentReachabilityStatus.hashValue
            return (networkStatus != 0)
        }
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
                for title in titles {
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
        
        delegate?.toggleRightPanel?()
        
        let currentLongDelta = appDelegate.myMapView.region.span.longitudeDelta
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(bibleLocations![0].lat,bibleLocations![0].long  - currentLongDelta/4)
        appDelegate.myMapView?.setCenter(center, animated: false)
        
        gesture?.isEnabled = true
        
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.toggleRightPanel!()
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(bibleLocations![0].lat,bibleLocations![0].long)
        appDelegate.myMapView?.setCenter(center, animated: false)
        gesture?.isEnabled = false
    }
    
    func chapterSelected() {
        chapSel = true
        delegate?.toggleRightPanel!()
    }
    

}

extension GlossaryViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

}
