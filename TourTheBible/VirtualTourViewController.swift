
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

@objc
protocol VirtualTourViewControllerDelegate {
    @objc optional func toggleRightPanel()
}

class VirtualTourViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, VirtualTourPanelViewControllerDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var fetchingAppearancesView: UIView!
    @IBOutlet weak var fetchingAppearancesAiv: UIActivityIndicatorView!
    @IBOutlet weak var fetchingAppearancesLabel: UILabel!
    
    var context: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
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
    var tour: AWSTour!
    var tappedLocation = ""
    var currentLat: Double?
    var currentLong: Double?
    
    var sites: [[Site]] = []
    var delegate: VirtualTourViewControllerDelegate?
    
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

    var chapterAppearances: [[Chapter]] = []
    var gesture: UITapGestureRecognizer!
    var whiteBackground: UIView?
    var chapSel = false
    var dimView: UIView!
    
    let books = Books.books
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false
        
        dimView = UIView(frame: self.view.bounds)
        dimView.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        
        context = appDelegate.managedObjectContext
        
        self.navItem.title = tour.name
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        appDelegate.myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: true)
        
        y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        height = screenSize.height - y!
        
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
        
        selectedBible = defaults.value(forKey: "selectedBible") as? String
        
        fetchingAppearancesView.isHidden = true
        fetchingAppearancesView.layer.cornerRadius = 10;
        fetchingAppearancesView.isUserInteractionEnabled = false
        
        adjustSubviews()
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.isEnabled = false
        self.view.addGestureRecognizer(gesture)
        
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        myTableView.isUserInteractionEnabled = true
        if appDelegate.tourState == .RightPanelExpanded {
            gesture?.isEnabled = false
            delegate?.toggleRightPanel!()
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLat!, currentLong!)
            appDelegate.myMapView?.setCenter(center, animated: true)
        } else {
            return
        }
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
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height

        height = screenSize.height - y
        
        appDelegate.myMapView.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: height!*0.45)
        myTableView.frame = CGRect(x: 0.0, y: height!*0.45, width: screenSize.width, height: height!*0.55)
        aiv.frame = CGRect(x: (screenSize.width/2) - 10, y: height!*0.45 + 55, width: 20, height: 20)
        noConnectionLabel.frame = CGRect(x: 0.0 , y: height!*0.45 + 55, width: screenSize.width, height: 100)
        
        let w = screenSize.width - 80.0
        fetchingAppearancesView.frame = CGRect(x: 40.0, y: (height!/2) - 40.0, width: w, height: 80.0)
        fetchingAppearancesAiv.frame = CGRect(x:0.0, y: 10.0, width: w, height: 30.0)
        fetchingAppearancesLabel.frame = CGRect(x: 10.0, y: 40.0, width: w - 20.0, height: 30.0)
        
        self.view.bringSubview(toFront: mapTypeButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let tbc = presentingViewController as! MainTabBarController
        let tvc = tbc.viewControllers![2].childViewControllers[0] as! VirtualTourTableViewController
        tvc.subscribeToKeyboardNotifications()
    }
    
    @IBAction func toursButtonPressed(_ sender: Any) {
        if appDelegate.currentState == .RightPanelExpanded {
            delegate?.toggleRightPanel!()
        }
        dismiss(animated: true, completion: nil)
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        tbc.selectedIndex = 2
    }
    
    func chapterSelected(vc: ContainerViewController) {
        chapSel = true
        delegate?.toggleRightPanel!()
        self.dismiss(animated: false, completion: {
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false, completion: nil)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingTableView()
        var convertedSites: [Site] = []
        if let tourSites = tour.sites {
            for site in tourSites {
                let newSite = Site(date: site["date"] as! String, lat: site["lat"] as! String, long: site["long"] as! String, name: site["name"] as! String, notes: site["notes"] as! String, stop: site["stop"] as! String)
                convertedSites.append(newSite)
            }
            
            convertedSites.sort { $0.date < $1.date }
            var tempArray: [Site] = []
            var lastSite = convertedSites[0]
            for site in convertedSites {
                if site.date == lastSite.date {
                    tempArray.append(site)
                } else {
                    tempArray.sort { $0.stop < $1.stop }
                    sites.append(tempArray)
                    tempArray = []
                    tempArray.append(site)
                }
                lastSite = site
            }
            sites.append(tempArray)
            
            myTableView.reloadData()
        }
        doneLoadingTableView()

    }
    
    func loadingTableView() {
        aiv.isHidden = false
        aiv.startAnimating()
        myTableView.isHidden = true
    }
    
    func doneLoadingTableView() {
        aiv.isHidden = true
        aiv.stopAnimating()
        myTableView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sites.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GlobalFunctions.shared.formatDate(date: sites[section][0].date)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let site = sites[indexPath.section][indexPath.row]
        cell.textLabel?.text = String(describing: site.stop!) + ". " + site.name
        return cell
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView()
    
        let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton
        pinView.rightCalloutAccessoryView = button
        
        pinView.canShowCallout = true
        pinView.annotation = annotation
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        showFetchingAppearancesView()
        tappedLocation = (view.annotation?.title!)!
        currentLat = view.annotation?.coordinate.latitude
        currentLong = view.annotation?.coordinate.longitude
        
        AWSClient.sharedInstance.getChapterAppearances(location: tappedLocation, completion: { (chapterAppearances, error) -> () in
            self.dismissFetchingAppearancesView()
            if let chapterAppearances = chapterAppearances {
                self.chapterAppearances = chapterAppearances
                self.delegate?.toggleRightPanel?()
                let currentLongDelta = self.appDelegate.myMapView.region.span.longitudeDelta
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentLat!, self.currentLong! - (currentLongDelta/4))
                self.appDelegate.myMapView?.setCenter(center, animated: true)
                self.myTableView.isUserInteractionEnabled = false
                self.gesture.isEnabled = true
            } else {
                print("error")
            }
        })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        plotPin(site: sites[indexPath.section][indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func plotPin(site: Site) {
        
        let coordinate = CLLocationCoordinate2D(latitude: site.lat, longitude: site.long)
        appDelegate.myMapView.setCenter(coordinate, animated: true)
        
        let allAnnotations = appDelegate.myMapView.annotations
        var shouldAddAnnotation = true
        var alreadyAddedAnnotation: MKAnnotation?
        
        for annotation in allAnnotations {
            if annotation.coordinate.latitude == site.lat && annotation.coordinate.longitude == site.long {
                shouldAddAnnotation = false
                alreadyAddedAnnotation = annotation
            }
        }
        
        if shouldAddAnnotation {
            
            let annotation = CustomPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: site.lat, longitude: site.long)
            annotation.title = site.name
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
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
