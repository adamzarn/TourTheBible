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
    
    @IBOutlet weak var myTableView: UITableView!
    
    let books = ["Matthew","Mark","Luke","John","Acts"]
    let summaries = Books.summaries
    
    var hasBeenShown = [Bool](repeating: false, count: Books.booksDictionary.count)
    
    override func viewDidLoad() {
        
        let imageView = UIImageView(image: UIImage(named: "Papyrus"))
        myTableView.backgroundView = imageView
        myTableView.backgroundView?.alpha = 0.4
        
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
        cell.detail.text = summaries[indexPath.row]
        
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
