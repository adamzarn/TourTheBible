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

class MapAndTextViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    var refreshControl = UIRefreshControl()
    var chapterTitles = [] as [String]
    var lastAnnotation: MKAnnotation?
    
    var menuView: BTNavigationDropdownMenu? = nil
    
    var index = 0
    var chapterIndex = 1
    var book = ""
    var numberOfChapters = 0
    var formerContentSize = 0.0 as CGFloat

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let coordinate = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
        
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)), animated: true)
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.addTarget(self, action: #selector(MapAndTextViewController.swipeLeft))
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.addTarget(self, action: #selector(MapAndTextViewController.swipeRight))
        self.view.addGestureRecognizer(swipeRight)
        
        for i in 1...numberOfChapters {
            chapterTitles.append("\(book) \(String(i))")
        }
        
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: "\(book) \(chapterIndex)",
                                                items: chapterTitles as [AnyObject])

        self.navItem.titleView = menuView
        menuView!.arrowTintColor = UIColor.black
        menuView!.shouldChangeTitleText = true
        
        menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.chapterIndex = indexPath + 1
            self.setUpText()
        }
        
        setUpText()
    
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
    }
    
    func swipeLeft() {
        
        if chapterIndex != numberOfChapters {
            chapterIndex += 1
        } else {
            return
        }
        
        swipeActions()
        
    }
    
    func swipeRight() {
        
        if chapterIndex != 1 {
            chapterIndex -= 1
        } else {
            return
        }
        
        swipeActions()

    }
    
    func swipeActions() {
        
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                 containerView: self.navigationController!.view,
                                                 title: "\(book) \(chapterIndex)",
            items: chapterTitles as [AnyObject])
        self.navItem.titleView = menuView
        menuView!.arrowTintColor = UIColor.black
        menuView!.shouldChangeTitleText = true
        
        menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.chapterIndex = indexPath + 1
            self.setUpText()
        }
        setUpText()
        myMapView.selectAnnotation(lastAnnotation!, animated: false)
        
    }


    func setUpText() {
        
        let text = Books.booksDictionary["\(book)"]![chapterIndex-1]
        let attributedText = NSMutableAttributedString(string: text)
        let allTextRange = (text as NSString).range(of: text)

        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Light", size:16.0)!, range: allTextRange)
        
        let dictionary = BibleLocations.Locations as NSDictionary
        let placesArray = dictionary.allKeys as! [String]
        
        for place in placesArray {
            
            var range = (text as NSString).range(of: place)
            var offset = 0
            let totalCharacters = text.characters.count
            
            while range.location < 10000000 {

                attributedText.addAttribute(NSFontAttributeName, value: UIFont(name:"Helvetica-Bold", size:16.0)!, range: range)
                attributedText.addAttribute(NSLinkAttributeName, value: place, range: range)
                
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
            if annotation.coordinate.latitude == lat {
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
        
        let location = BibleLocations.Locations[URL.absoluteString]! as BibleLocation
        setUpMap(name: location.name!, lat: location.lat!, long: location.long!, delta: location.delta!)
        
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
    
    @IBAction func clearMapButtonPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let removePins = UIAlertAction(title: "Remove Pins", style: .default) { (action) in
            self.myMapView.removeAnnotations(self.myMapView.annotations)
        }
        let removeRoutes = UIAlertAction(title: "Remove Routes", style: .default) { (action) in
            self.myMapView.removeOverlays(self.myMapView.overlays)
        }
        let removeAll = UIAlertAction(title: "Clear All", style: .default) { (action) in
            self.myMapView.removeOverlays(self.myMapView.overlays)
            self.myMapView.removeAnnotations(self.myMapView.annotations)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removePins)
        alertController.addAction(removeRoutes)
        alertController.addAction(removeAll)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //if overlay is MKPolyline {
        //    let lineView = MKPolylineRenderer(overlay: overlay)
        //    lineView.strokeColor = UIColor.redColor()
        
        //    return lineView
        //}
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 3.0
            renderer.alpha = 0.5
            renderer.strokeColor = UIColor.blue
            return renderer
        }
        
        return MKPolylineRenderer()
    }
    
    func getDirections() {
        
        //let request = MKDirectionsRequest()
        //request.source = MKMapItem(placemark: MKPlacemark(coordinate: sources[directionsIndex], addressDictionary: nil))
        //request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations[directionsIndex], addressDictionary: nil))
        //request.transportType = .Automobile
        
        //let directions = MKDirections(request: request)
        //directions.calculateDirectionsWithCompletionHandler { response, error in
        //if let response = response {
        //print(response.description)
        //} else {
        //print(error!.description)
        //}
        //guard let unwrappedResponse = response else {
        
        
        //            let pointsArray = routes[index]
        //                print(pointsArray)
        //
        //                let pointsCount = pointsArray.count
        //                print(pointsCount)
        //
        //                var pointsToUse: [CLLocationCoordinate2D] = []
        //
        //                for i in 0...pointsCount-1 {
        //                    let p = CGPointFromString(pointsArray[i])
        //                    pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y))]
        //                }
        
        //let geodesicPolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: pointsCount)
        
        //self.myMapView.add(geodesicPolyline)
        
        //return
        
        //}
        
        //for route in unwrappedResponse.routes {
        //self.myMapView.addOverlay(route.polyline)
        //self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        //self.directionsIndex += 1
        //}
        
        //}
    }


}

