//
//  Alerts.swift
//  TourTheBible
//
//  Created by Adam Zarn on 12/1/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayBookNotPurchasedAlert(book: String) {
        let alert = UIAlertController(title: "Book not Purchased", message: "In order to view this content, you must first purchase the book of \(book).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
