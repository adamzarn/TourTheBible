//
//  BooksTableViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 9/13/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class BooksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myOTTableView: UITableView!
    @IBOutlet weak var myNTTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var window: UIWindow?
    
    let testaments = ["Old Testament", "New Testament"]
    let OTbooks = ["Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth","1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi"]
    let NTbooks = ["Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"]
    
    var hasBeenShown = [[Bool](repeating: false, count: 39), [Bool](repeating: false, count: 27)]
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        let width = self.view.bounds.size.width
        
        let y = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        let height = self.view.bounds.size.height - y - (tabBarController?.tabBar.frame.size.height)!
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        myOTTableView.frame = CGRect(x: 0.0, y: y, width: width/2, height: height)
        
        myNTTableView.frame = CGRect(x: width/2, y: y, width: width/2, height: height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BooksTableViewController.reachabilityChanged), name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"), object: nil)
        
        let restoreButton = UIBarButtonItem(title: "Restore",
                                            style: .plain,
                                            target: self,
                                            action: #selector(BooksTableViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(BooksTableViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)

    }
    
    deinit {
        print("BooksTableViewController destroyed.")
    }

    func reachabilityChanged() {
        reload()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.myMapView.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.myYouTubePlayer.stopVideo()
        appDelegate.myYouTubePlayer.isHidden = true
        appDelegate.myMapView.isHidden = false
    }
    
    func reload() {
        
        if FirebaseClient.sharedInstance.hasConnectivity() {
            if appDelegate.products.count == 0 {
                Products.store.requestProducts{success, products in
                    if success {
                        self.appDelegate.products = products!
                        self.myOTTableView.reloadData()
                        self.myNTTableView.reloadData()
                    }
                }
            }
        }
        myOTTableView.reloadData()
        myNTTableView.reloadData()
    }
    
    func restoreTapped(_ sender: AnyObject) {
        Products.store.restorePurchases()
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        var row = 0
        for book in OTbooks {
            if productID != "AJZ.WalkThroughTheBible.\(book)" {
                row += 1
            } else {
                self.myOTTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
            }
        }
        
        row = 0
        for book in NTbooks {
            if productID != "AJZ.WalkThroughTheBible.\(book)" {
                row += 1
            } else {
                self.myNTTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var section = 0
        if tableView == myNTTableView {
            section = 1
        }
        
        if !hasBeenShown[section][indexPath.row] {
        
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
                
        }
        
        hasBeenShown[section][indexPath.row] = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var bookName = ""
        var productNames: [String] = []
        var productID = ""
        var productCellID = ""
        var bookCellID = ""
        
        if tableView == myOTTableView {
        
            bookName = OTbooks[indexPath.row]
            productNames = ["Exodus","Numbers"]
            productID = "AJZ.WalkThroughTheBible.\(OTbooks[indexPath.row])"
            productCellID = "OTProductCell"
            bookCellID = "OTBookCell"
            
        } else {
            
            bookName = NTbooks[indexPath.row]
            productNames = ["Acts"]
            productID = "AJZ.WalkThroughTheBible.\(NTbooks[indexPath.row])"
            productCellID = "NTProductCell"
            bookCellID = "NTBookCell"
            
        }
        
        if productNames.contains(bookName) {

            if !defaults.bool(forKey: productID) {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: productCellID) as! ProductCell
                cell.delegate = self
                
                if appDelegate.products.count > 0 {
                    
                    cell.aiv.stopAnimating()
                    cell.setUp(aivHidden: true, bookHidden: false, priceHidden: false, priceEnabled: true)
                    
                    var product = SKProduct()
                    
                    for prod in appDelegate.products {
                        if prod.localizedTitle == bookName {
                            product = prod
                        }
                    }
                
                    cell.product = product
                    cell.buyButtonHandler = { product in
                    Products.store.buyProduct(product)
                    }
                
                    cell.setUp()
                    
                } else {
                    
                    if FirebaseClient.sharedInstance.hasConnectivity() {
                        cell.setUp(aivHidden: false, bookHidden: true, priceHidden: true, priceEnabled: false)
                        cell.aiv.startAnimating()
                    } else {
                        cell.setUp(aivHidden: true, bookHidden: false, priceHidden: false, priceEnabled: true)
                        cell.book.text = bookName
                        cell.price.isHidden = false
                        cell.price.isEnabled = true
                        cell.book.textColor = UIColor.lightGray
                        let priceString = "  $0.99  "
                        cell.price.setTitle(priceString, for: .normal)
                        cell.setUp()
                    }
                }
                
                return cell
                
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: bookCellID) as! CustomBookCell
            
        cell.book.text = bookName
        cell.setUp()
                
        return cell
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == myOTTableView {
            return testaments[0]
        } else {
            return testaments[1]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myOTTableView {
            return OTbooks.count
        } else {
            return NTbooks.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var productID = ""
        let containerViewController = ContainerViewController()
        if tableView == myOTTableView {
            productID = "AJZ.WalkThroughTheBible.\(OTbooks[indexPath.row])"
            if !["Exodus","Numbers"].contains(OTbooks[indexPath.row]) || defaults.bool(forKey: productID) {
                containerViewController.book = OTbooks[indexPath.row]
                if let chapterIndex = defaults.value(forKey: OTbooks[indexPath.row]) {
                    containerViewController.chapterIndex = chapterIndex as! Int
                } else {
                    containerViewController.chapterIndex = 1
                }
                self.present(containerViewController, animated: false, completion: nil)
            }
        } else {
            productID = "AJZ.WalkThroughTheBible.\(NTbooks[indexPath.row])"
            if !["Acts"].contains(OTbooks[indexPath.row]) || defaults.bool(forKey: productID) {
                containerViewController.book = NTbooks[indexPath.row]
                if let chapterIndex = defaults.value(forKey: NTbooks[indexPath.row]) {
                    containerViewController.chapterIndex = chapterIndex as! Int
                } else {
                    containerViewController.chapterIndex = 1
                }
                self.present(containerViewController, animated: false, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    func hasConnectivity() -> Bool {
        do {
            let reachability = Reachability()
            let networkStatus: Int = reachability!.currentReachabilityStatus.hashValue
            return (networkStatus != 0)
        }
    }

}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func removeItalics()-> UIFont {
        var symTraits = self.fontDescriptor.symbolicTraits
        if symTraits.contains(.traitItalic) {
            symTraits.remove([.traitItalic])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
        return self
    }
    
    func italicize() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
}
