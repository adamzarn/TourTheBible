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
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var window: UIWindow?
    
    let testaments = ["Old Testament", "New Testament"]
    let books = [["Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth","1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi"],["Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"]]
    
    var hasBeenShown = [[Bool](repeating: false, count: 39), [Bool](repeating: false, count: 27)]
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(BooksTableViewController.reachabilityChanged), name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"), object: nil)
        
        let tabBar = self.tabBarController?.tabBar
        let bookItem = tabBar?.items?[0]
        let glossaryItem = tabBar?.items?[1]
        let tourItem = tabBar?.items?[2]
        let biblesItem = tabBar?.items?[3]
        let aboutItem = tabBar?.items?[4]
        
        bookItem?.image = resizeImage(image: UIImage(named:"Book")!)
        glossaryItem?.image = resizeImage(image: UIImage(named:"List")!)
        tourItem?.image = resizeImage(image: UIImage(named:"Tourist")!)
        biblesItem?.image = resizeImage(image: UIImage(named:"Bibles")!)
        aboutItem?.image = resizeImage(image: UIImage(named:"About")!)
        
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
    
    func resizeImage(image: UIImage) -> UIImage {
        let newWidth = image.size.width/1.75
        let newHeight = image.size.height/1.75
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
 
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        reload()
    }
    
    func reload() {
        
        if hasConnectivity() {
            if appDelegate.products.count == 0 {
                Products.store.requestProducts{success, products in
                    if success {
                        self.appDelegate.products = products!
                        self.myTableView.reloadData()
                    }
                }
            }
        }
        myTableView.reloadData()
    }
    
    func restoreTapped(_ sender: AnyObject) {
        Products.store.restorePurchases()
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        var row = 0
        var section = 0
        for testament in books {
            for book in testament {
                if productID != "AJZ.WalkThroughTheBible.\(book)" {
                    row += 1
                } else {
                    self.myTableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .fade)
                }
            }
            row = 0
            section += 1
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !hasBeenShown[indexPath.section][indexPath.row] {
        
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
                
        }
        
        hasBeenShown[indexPath.section][indexPath.row] = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookName = books[indexPath.section][indexPath.row]
        let productNames = ["Exodus","Numbers","Acts"]
        let productID = "AJZ.WalkThroughTheBible.\(books[indexPath.section][indexPath.row])"
        
        if productNames.contains(bookName) {

            if !defaults.bool(forKey: productID) {
                
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
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
                        if hasConnectivity() {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! CustomBookCell
            
        cell.book.text = bookName
        cell.setUp()
                
        return cell
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return testaments[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let productID = "AJZ.WalkThroughTheBible.\(books[indexPath.section][indexPath.row])"
        
        if !["Exodus","Numbers","Acts"].contains(books[indexPath.section][indexPath.row]) || defaults.bool(forKey: productID) {
            
            let containerViewController = ContainerViewController()
            containerViewController.book = books[indexPath.section][indexPath.row]
            self.present(containerViewController, animated: false, completion: nil)

            tableView.deselectRow(at: indexPath, animated: true)
            
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
