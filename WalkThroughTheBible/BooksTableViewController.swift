//
//  BooksTableViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/13/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class BooksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let books = [["Genesis","Exodus","Numbers"],["Matthew","Mark","Luke","John","Acts"]]
    let summaries = Books.summaries
    
    var hasBeenShown = [[Bool](repeating: false, count: 3), [Bool](repeating: false, count: 5)]
    var testamentIndex = 0
    var products = [SKProduct]()
        
    override func viewDidLoad() {
        
        let imageView = UIImageView(image: UIImage(named: "Papyrus"))
        myTableView.backgroundView = imageView
        myTableView.backgroundView?.alpha = 0.4
        
        let restoreButton = UIBarButtonItem(title: "Restore",
                                            style: .plain,
                                            target: self,
                                            action: #selector(BooksTableViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(BooksTableViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    func reload() {
        
        products = []
        
        myTableView.reloadData()
        
        Products.store.requestProducts{success, products in
            if success {
                self.products = products!
                self.myTableView.reloadData()
            }
        }
    }
    
    func restoreTapped(_ sender: AnyObject) {
        Products.store.restorePurchases()
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            self.myTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !hasBeenShown[testamentIndex][indexPath.row] {
        
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
                
        }
        
        hasBeenShown[testamentIndex][indexPath.row] = true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookName = books[testamentIndex][indexPath.row]
        let bookDetail = summaries[testamentIndex][indexPath.row]
        
        let productID = "AJZ.WalkThroughTheBible.\(books[testamentIndex][indexPath.row])"
        
        if Products.productIdentifiers.contains(productID) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
            
            if products.count > 0 {
                
                cell.aiv.stopAnimating()
                
                cell.aiv.isHidden = true
                cell.book.isHidden = false
                cell.detail.isHidden = false
                cell.price.isHidden = false
                cell.price.isEnabled = true
                
                var product = SKProduct()
                
                for prod in products {
                    if prod.localizedTitle == bookName {
                        product = prod
                    }
                }
            
                cell.product = product
                cell.buyButtonHandler = { product in
                Products.store.buyProduct(product)
                }
            
                cell.setUp()
                cell.detail.text = bookDetail
                
            } else {
                
                cell.backgroundColor = UIColor.clear
                cell.book.isHidden = true
                cell.detail.isHidden = true
                cell.aiv.isHidden = false
                cell.price.isHidden = true
                cell.price.isEnabled = false
                
                cell.aiv.startAnimating()

            }
            
            return cell
    
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! CustomBookCell
        
            cell.book.text = bookName
            cell.detail.text = bookDetail
        
            cell.setUp()
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books[testamentIndex].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let productID = "AJZ.WalkThroughTheBible.\(books[testamentIndex][indexPath.row])"
        
        if (Products.productIdentifiers.contains(productID) && Products.store.isProductPurchased(productID)) || !Products.productIdentifiers.contains(productID) {
        
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapAndTextViewController") as! MapAndTextViewController
            vc.book = books[testamentIndex][indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }

    
}
