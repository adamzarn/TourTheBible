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
import AWSCore
import AWSDynamoDB

@objc
protocol GlossaryViewControllerDelegate {
    @objc optional func toggleRightPanel()
}

class GlossaryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, YTPlayerViewDelegate, GlossaryPanelViewControllerDelegate {
    
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
    
    @IBOutlet weak var fetchingAppearancesView: UIView!
    @IBOutlet weak var fetchingAppearancesLabel: UILabel!
    @IBOutlet weak var fetchingAppearancesAiv: UIActivityIndicatorView!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    let searchController = UISearchController(searchResultsController: nil)
    var sortedGlossary = [[BibleLocation]](repeating: [], count: 26)
    var masterGlossary = [BibleLocation]()
    var filteredGlossary = [BibleLocation]()
    var masterSongList = [Video]()
    var filteredSongList = [Video]()
    let letters = Books.letters
    let books = Books.books
    let booksAbbreviated = Books.booksAbbreviated
    
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
    var songBooksAbbreviated: [String] = []
    var delegate: GlossaryViewControllerDelegate?
    
    var selectedLocations: [BibleLocation] = []
    var tappedBibleLocation: BibleLocation?
    var tappedLocation: String = ""
    var chapterAppearances: [[Chapter]] = []
    var bookAppearances: [String] = []
    var gesture: UITapGestureRecognizer?
    var chapSel = false
    var dimView: UIView!

    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        screenSize = self.view.bounds
        
        dimView = UIView(frame: self.view.bounds)
        dimView.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        
        context = appDelegate.managedObjectContext
        
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
        
        mapTypeButton.setTitle(" Satellite ", for: .normal)
        mapTypeButton.layer.borderWidth = 1
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.view.bringSubview(toFront: mapTypeButton)
        
        fetchingAppearancesView.isHidden = true
        fetchingAppearancesView.layer.cornerRadius = 10;
        fetchingAppearancesView.isUserInteractionEnabled = false
        
        adjustSubviews()
        
        populateGlossary()
        
    }
    
    func loadingTableView() {
        myTableView.isHidden = true
        aiv.isHidden = false
        aiv.startAnimating()
    }
    
    func doneLoadingTableView() {
        self.myTableView.isHidden = false
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
    }
    
    func populateGlossary() {
        loadingTableView()
        AWSClient.sharedInstance.getBibleLocations(completion: { (bibleLocations, error) -> () in
            if let bibleLocations = bibleLocations {
                self.masterGlossary = bibleLocations
                self.segmentedControl.setTitle("Locations (\(self.masterGlossary.count))", forSegmentAt: 0)
                self.sortGlossary()
                self.myTableView.reloadData()
                self.doneLoadingTableView()
            } else {
                self.doneLoadingTableView()
            }
        })
    }
    
    func sortGlossary() {
        masterGlossary.sort { $0.name < $1.name }
        for bibleLocation in masterGlossary {
            let name = bibleLocation.name
            var i = 0
            for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
                if name[name.startIndex] == char {
                    sortedGlossary[i].append(bibleLocation)
                }
                i += 1
            }
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
        let h = appDelegate.tabBarHeight!
        height = screenSize.height - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.size.height - h
        let YTPlayerHeight = (screenSize.width/16)*9
        appDelegate.myYouTubePlayer.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: YTPlayerHeight)
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: (height!+h)*0.45)
        segmentedControl.frame = CGRect(x: 5, y: (height!+h)*0.45 + 5, width: screenSize.width - 10, height: 30)
        myTableView.frame = CGRect(x: 0.0, y: (height!+h)*0.45 + 40, width: screenSize.width, height: (height!+h)*0.55 - 40 - h)
        aiv.frame = CGRect(x: (screenSize.width/2) - 10, y: (height!+h)*0.45 + (myTableView.frame.size.height/2) + 40, width: 20, height: 20)
        viewInYouTubeButton.frame = CGRect(x: 5.0, y: YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height! + h)*0.45 - YTPlayerHeight - 10.0)
        viewYouTubeChannelButton.frame = CGRect(x: (screenSize.width/2) + 2.5, y: YTPlayerHeight + 5.0, width: (screenSize.width/2) - 7.5, height: (height! + h)*0.45 - YTPlayerHeight - 10.0)
        loadingLabel.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: YTPlayerHeight)
        nothingToDisplayLabel.frame = CGRect(x: 0.0 , y: (height!+h)*0.45 + 55, width: screenSize.width, height: 100)
        
        let w = screenSize.width - 80.0
        fetchingAppearancesView.frame = CGRect(x: 40.0, y: (height!/2) - 40.0, width: w, height: 80.0)
        fetchingAppearancesAiv.frame = CGRect(x:0.0, y: 10.0, width: w, height: 30.0)
        fetchingAppearancesLabel.frame = CGRect(x: 10.0, y: 40.0, width: w - 20.0, height: 30.0)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredGlossary = masterGlossary.filter { location in
                return (location.name.lowercased().contains(searchText.lowercased()))
            }
        } else {
            filteredSongList = masterSongList.filter { video in
                let vc = video.verses.split{$0 == ":"}.map(String.init)
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
            //myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            showMap()
        } else {
            if songBooks.count > 0 {
                //myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
            
            let annotation = CustomPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            annotation.title = pin.title
            if let subtitle = pin.subtitle {
                annotation.name = subtitle
                if pin.title != subtitle {
                    annotation.subtitle = subtitle
                }
            } else {
                annotation.name = pin.title
            }
            appDelegate.myMapView.addAnnotation(annotation)
            let newLoc = BibleLocation(name: pin.title ?? pin.subtitle ?? "", lat: pin.lat, long: pin.long)
            selectedLocations.append(newLoc)
            
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
        return songBooksAbbreviated
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return letters.index(of: title)!
        }
        return songBooksAbbreviated.index(of: title)!
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

        let vc = video?.verses.split{$0 == ":"}.map(String.init)
        let chapterIndexString = vc?[0]
        let chapterIndex = Int(chapterIndexString!)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let goToScripture = UIAlertAction(title: "Go to \(book!) \(chapterIndex!)", style: .default) { (action) in
            let prefix = "AJZ.WalkThroughTheBible."
            if !self.defaults.bool(forKey:"\(prefix)\(book!)") && ["Exodus","Numbers","Acts"].contains(book!) {
                self.displayBookNotPurchasedAlert(book: book!)
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                let containerViewController = ContainerViewController()
                containerViewController.book = book
                containerViewController.chapterIndex = chapterIndex!
                self.present(containerViewController, animated: false, completion: nil)
            }
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
                selectedLocations.append(location)
                plotPin(loc: location)
                savePin(location: location!)
                y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                height = screenSize.height - y! - (tabBarController?.tabBar.frame.size.height)!
                tableView.frame = CGRect(x: 0.0, y: y! + height!*0.45 + 40, width: screenSize.width, height: height!*0.55 - 40)
                self.view.bringSubview(toFront: mapTypeButton)
                searchController.dismiss(animated: true, completion: nil)
                searchController.searchBar.text = ""
                
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.reloadData()
                
            } else {
                let location = sortedGlossary[indexPath.section][indexPath.row] as BibleLocation
                selectedLocations.append(location)
                plotPin(loc: location)
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
        newPin.setValue(location.name, forKey: "subtitle")
        newPin.setValue(currentBook, forKey: "pinToBook")
        pinsForBook.append(newPin)

        appDelegate.saveContext()
        
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
        
        if shouldAddAnnotation {
            
            let annotation = CustomPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.long)
            annotation.title = loc.name
            annotation.name = loc.name
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
            self.selectedLocations = []
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
        if segmentedControl.selectedSegmentIndex == 1 && !FirebaseClient.sharedInstance.hasConnectivity() {
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
        myTableView.frame = CGRect(x: 0.0, y: height!*0.45 + 40, width: screenSize.width, height: height!*0.55 - 40)
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
        myTableView.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: height!)
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
        loadingTableView()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            myTableView.reloadData()
            doneLoadingTableView()
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
                                    self.songBooksAbbreviated.append(self.booksAbbreviated[bookSequence])
                                    let unsortedVideos = videoLibrary[book]
                                    var tempVideos: [Video] = []
                                    for video in unsortedVideos! {
                                        let vc = video.verses.split{$0 == ":"}.map(String.init)
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
                            self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                            self.doneLoadingTableView()
                            if self.appDelegate.myYouTubePlayer.playerState() == YTPlayerState.queued {
                                self.searchController.searchBar.placeholder = "Search"
                                self.searchController.searchBar.isUserInteractionEnabled = true
                                self.segmentedControl.isUserInteractionEnabled = true
                            }
                        }
                    })
                } else {
                    myTableView.reloadData()

                    myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    self.doneLoadingTableView()
                }
                showYouTube(videoID: "HLE8Xjuqn2M")
            } else {
                showYouTube(videoID: "HLE8Xjuqn2M")
                appDelegate.myYouTubePlayer.isHidden = true
                loadingLabel.text = "No Internet Connection"
                nothingToDisplayLabel.isHidden = false
                doneLoadingTableView()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        showFetchingAppearancesView()
        tappedLocation = (view.annotation as! CustomPointAnnotation).name!
        setTappedBibleLocation(name: tappedLocation)
        
        if let loc = tappedBibleLocation {
            AWSClient.sharedInstance.getChapterAppearances(location: loc.name, completion: { (chapterAppearances, error) -> () in
                self.dismissFetchingAppearancesView()
                if let chapterAppearances = chapterAppearances {
                    self.chapterAppearances = chapterAppearances
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GlossaryPanelViewController") as! GlossaryPanelViewController
                    vc.chapterAppearances = chapterAppearances
                    vc.tappedLocation = self.tappedLocation
                    vc.delegate = self
                    vc.title = loc.name
                    self.navigationController?.pushViewController(vc, animated: false)
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
    
    func setTappedBibleLocation(name: String) {
        for loc in selectedLocations {
            if loc.name == name {
                tappedBibleLocation = loc
            }
        }
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.toggleRightPanel!()
        setTappedBibleLocation(name: self.tappedLocation)
        if let loc = tappedBibleLocation {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.lat,loc.long)
            appDelegate.myMapView?.setCenter(center, animated: true)
        }
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
