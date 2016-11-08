//
//  ProductCell.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 10/4/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import StoreKit

class ProductCell: UITableViewCell {
    
    func setUp() {
        self.backgroundColor = UIColor.clear
        //book.font = UIFont(name: "Papyrus", size: 35.0)
        book.font = UIFont.systemFont(ofSize: 24.0)
        price.layer.cornerRadius = 5
        price.layer.borderWidth = 1
        price.backgroundColor = UIColor.white
    }
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var book: UILabel!
    @IBOutlet weak var price: UIButton!
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
        
    }()
    
    var buyButtonHandler: ((_ product: SKProduct) -> ())?
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            book.text = product.localizedTitle
            
            if Products.store.isProductPurchased(product.productIdentifier) {
                
                price.isHidden = true
                price.isEnabled = false
                book.textColor = UIColor.black
                
            } else if IAPHelper.canMakePayments() {
                
                price.isHidden = false
                price.isEnabled = true
                book.textColor = UIColor.lightGray
                ProductCell.priceFormatter.locale = product.priceLocale
                let pString = ProductCell.priceFormatter.string(from: product.price)!
                let priceString = "  \(pString)  "
                price.setTitle(priceString, for: .normal)
                
            } else {
                
                price.isEnabled = false
                
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel?.text = ""
        detailTextLabel?.text = ""
        accessoryView = nil
    }
    
    @IBAction func buyButtonTapped(_ sender: AnyObject) {
        buyButtonHandler?(product!)
    }
}

