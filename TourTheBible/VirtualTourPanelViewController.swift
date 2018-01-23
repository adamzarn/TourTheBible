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
    var chapterAppearances: [[Chapter]] = []
    var tappedLocation: String = ""
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
        return chapterAppearances.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (chapterAppearances[section][0]).book
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterAppearances[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CustomTableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "glossaryAppearancesCell") as! CustomTableViewCell
        let currentChapter = chapterAppearances[indexPath.section][indexPath.row]
        cell.textLabel?.text = currentChapter.book + " " + String(currentChapter.chapterNumber)
        cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        return cell
    }
    
}

// Mark: Table View Delegate

extension VirtualTourPanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let currentChapter = chapterAppearances[indexPath.section][indexPath.row]
        
        let book = currentChapter.book
        let chapterIndex = currentChapter.chapterNumber
        
        let prefix = "AJZ.WalkThroughTheBible."
        if !defaults.bool(forKey:"\(prefix)\(book)") && ["Exodus","Numbers","Acts"].contains(book) {
            let alert = UIAlertController(title: "Book not Purchased", message: "In order to view this content, you must first purchase the book of \(book).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let containerViewController = ContainerViewController()
            containerViewController.dismissButtonText = "Virtual Tours"
            containerViewController.book = book
            containerViewController.chapterIndex = chapterIndex
            delegate?.chapterSelected!(vc: containerViewController)
        }
        
    }
    
}
