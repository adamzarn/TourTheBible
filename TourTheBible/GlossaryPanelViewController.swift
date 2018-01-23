//
//  GlossaryPanelViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/13/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit

@objc
protocol GlossaryPanelViewControllerDelegate {
    @objc optional func chapterSelected()
}

class GlossaryPanelViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    @IBOutlet var rightView: UIView!
    @IBOutlet weak var appearanceTableView: UITableView!
    
    var chapterAppearances: [[Chapter]] = []
    var tappedLocation: String = ""
    var currentBook: String = ""
    var delegate: GlossaryPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        for book in chapterAppearances {
            for chapter in book {
                print(chapter.book, chapter.chapterNumber)
            }
        }
        
    }

}

// MARK: Table View Data Source

extension GlossaryPanelViewController: UITableViewDataSource {
    
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

extension GlossaryPanelViewController: UITableViewDelegate {
    
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
            containerViewController.dismissButtonText = "Glossary"
            containerViewController.book = book
            containerViewController.chapterIndex = chapterIndex
            self.present(containerViewController, animated: false, completion: nil)
            delegate?.chapterSelected!()
        }
        
    }
    
}

