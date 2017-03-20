//
//  VirtualTourPanelViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/14/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit

@objc
protocol VirtualTourPanelViewControllerDelegate {
    @objc optional func chapterSelected(vc: ContainerViewController)
}

class VirtualTourPanelViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    @IBOutlet var rightView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var appearanceTableView: UITableView!
    
    var chapterTitles: [String] = []
    var chapterAppearances: [[String]] = [[]]
    var bookAppearances: [String] = []
    var tappedLocation: String = ""
    var tappedLocationKey: String = ""
    var subtitles: [[String]] = [[]]
    var currentBook: String = ""
    var delegate: VirtualTourPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let screenSize = UIScreen.main.bounds
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        locationButton.frame = CGRect(x:16,y:statusBarHeight + 12,width:screenSize.width/2 - 32,height:41)
        locationButton.setTitle(tappedLocation,for: .normal)
        locationButton.titleLabel?.font = UIFont(name: "Papyrus", size: 24.0)
        locationButton.isUserInteractionEnabled = false
        locationButton.titleLabel?.numberOfLines = 1
        locationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        appearanceTableView.frame = CGRect(x: 0.0, y: statusBarHeight + 60.0, width: screenSize.width, height: screenSize.height - 60.0 - statusBarHeight)
        
    }
    
}

// MARK: Table View Data Source

extension VirtualTourPanelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if appDelegate.tourState == .RightPanelExpanded {
            return bookAppearances.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if appDelegate.tourState == .RightPanelExpanded {
            return bookAppearances[section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appDelegate.tourState == .RightPanelExpanded {
            return chapterAppearances[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CustomTableViewCell()
        if appDelegate.tourState == .RightPanelExpanded {
            cell = tableView.dequeueReusableCell(withIdentifier: "glossaryAppearancesCell") as! CustomTableViewCell
            cell.textLabel?.text = chapterAppearances[indexPath.section][indexPath.row]
            if subtitles[indexPath.section][indexPath.row].caseInsensitiveCompare(tappedLocation) != ComparisonResult.orderedSame {
                cell.detailTextLabel?.text = subtitles[indexPath.section][indexPath.row]
            } else {
                cell.detailTextLabel?.text = ""
            }
            cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        }
        return cell
    }
    
}

// Mark: Table View Delegate

extension VirtualTourPanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var chapterString = ""
        
        chapterString = chapterAppearances[indexPath.section][indexPath.row]
        
        let splitArray = chapterString.components(separatedBy: " ")
        var book = ""
        for i in 0...splitArray.count - 2 {
            book = "\(book) \(splitArray[i])"
        }
        book = book.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let chapterIndex = Int(splitArray[splitArray.count-1])
        
        let prefix = "AJZ.WalkThroughTheBible."
        if !defaults.bool(forKey:"\(prefix)\(book)") && ["Exodus","Numbers","Acts"].contains(book) {
            let alert = UIAlertController(title: "Book not Purchased", message: "In order to view this content, you must first purchase the book of \(book).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let containerViewController = ContainerViewController()
            containerViewController.book = book
            containerViewController.chapterIndex = chapterIndex!
            delegate?.chapterSelected!(vc: containerViewController)
        }
        
    }
    
}
