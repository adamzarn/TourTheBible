//
//  SidePanelViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 12/2/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

@objc
protocol SidePanelViewControllerDelegate {
    @objc optional func loadText(chapterIndex: Int, shouldToggle: Bool)
}

class SidePanelViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var myTableView: UITableView!
    var chapterTitles: [String] = []
    var delegate: SidePanelViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let index = NSIndexPath(row: appDelegate.chapterIndex-1, section: 0) as IndexPath
        myTableView.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: false)
    }
    
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = chapterTitles[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        return cell
    }
    
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.loadText?(chapterIndex:indexPath.row+1, shouldToggle: true)
    }
    
}

