//
//  BooksTableViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/13/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class BooksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let books = [["Genesis","Exodus","Leviticus","Numbers","Deuteronomy"],["Matthew","Mark","Luke","John","Acts"]]
    let summaries = Books.summaries
    
    var hasBeenShown = [[Bool](repeating: false, count: 5), [Bool](repeating: false, count: 5)]
    var testamentIndex = 0
        
    override func viewDidLoad() {
        
        let imageView = UIImageView(image: UIImage(named: "Papyrus"))
        myTableView.backgroundView = imageView
        myTableView.backgroundView?.alpha = 0.4
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomBookCell
        
        cell.book.text = books[testamentIndex][indexPath.row]
        cell.detail.text = summaries[testamentIndex][indexPath.row]

        
        cell.setUp()

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books[testamentIndex].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapAndTextViewController") as! MapAndTextViewController
        vc.book = books[testamentIndex][indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
            
        
    }

    
}
