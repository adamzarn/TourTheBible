//
//  BooksTableViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/13/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class BooksTableViewController: UIViewController, UITableViewDelegate {
    
    let books = ["Matthew","Mark"]
    
    let details = ["Visit Jesus in the manger, flee from Herod to Egypt, settle down in Nazareth, follow Jesus to Caesarea Philippi, join the disciples for the last supper, and see Jesus resurrected."
        , "Witness the baptism of Jesus, watch Jesus calm a storm on the Sea of Galilee, go up the mount of transfiguration, enter Jerusalem for the Passover, and see the empty tomb."]
    
    var hasBeenShown = [Bool](repeating: false, count: Books.booksDictionary.count)
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSFontAttributeName: UIFont(name:"Helvetica-Bold", size:16.0)!]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !hasBeenShown[indexPath.row] {
        
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
                
        }
        
        hasBeenShown[indexPath.row] = true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomBookCell
        
        cell.book.text = books[indexPath.row]
        cell.detail.text = details[indexPath.row]
        
        cell.setUp()

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapAndTextViewController") as! MapAndTextViewController
        vc.book = books[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }



    
}
