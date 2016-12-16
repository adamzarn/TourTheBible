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
    @objc optional func reloadMapTextView(book: String, chapterIndex: Int, shouldToggle: Bool, shouldReloadMap: Bool)
    @objc optional func booksButtonPressed()
}

class SidePanelViewController: UIViewController {
    
    let books = ["Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth","1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi","Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"]
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var booksButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    @IBOutlet var rightView: UIView!
    @IBOutlet weak var appearanceTableView: UITableView!
    @IBOutlet weak var myTableView: UITableView!
    var chapterTitles: [String] = []
    var chapterAppearances: [[String]] = [[]]
    var bookAppearances: [String] = []
    var tappedLocation: String = ""
    var tappedLocationKey: String = ""
    var subtitles: [[String]] = [[]]
    var currentBook: String = ""
    var delegate: SidePanelViewControllerDelegate?
    
    override func viewDidLoad() {
        
        if appDelegate.currentState == .LeftPanelWillExpand {
            booksButton.titleLabel?.font = UIFont(name: "Papyrus", size: 24.0)
            self.automaticallyAdjustsScrollViewInsets = false
        } else {
            let screenSize = UIScreen.main.bounds
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            locationButton.frame = CGRect(x:16,y:statusBarHeight + 12,width:screenSize.width/2 - 32,height:41)
            locationButton.setTitle(tappedLocation,for: .normal)
            locationButton.titleLabel?.font = UIFont(name: "Papyrus", size: 24.0)
            locationButton.isUserInteractionEnabled = false
            locationButton.titleLabel?.numberOfLines = 1
            locationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appDelegate.currentState == .LeftPanelExpanded {
            let index = NSIndexPath(row: appDelegate.chapterIndex-1, section: 0) as IndexPath
            myTableView.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: false)
        }
    }
    
    @IBAction func booksButtonPressed(_ sender: Any) {
        delegate?.booksButtonPressed!()
    }
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if appDelegate.currentState == .LeftPanelExpanded {
            return 1
        } else if appDelegate.currentState == .RightPanelExpanded {
            return bookAppearances.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if appDelegate.currentState == .LeftPanelExpanded {
            return "Chapters"
        } else if appDelegate.currentState == .RightPanelExpanded {
            return bookAppearances[section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appDelegate.currentState == .LeftPanelExpanded {
            return chapterTitles.count
        } else if appDelegate.currentState == .RightPanelExpanded {
            return chapterAppearances[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if appDelegate.currentState == .LeftPanelExpanded {
            cell = tableView.dequeueReusableCell(withIdentifier: "chaptersCell")!
            cell.textLabel?.text = chapterTitles[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        } else if appDelegate.currentState == .RightPanelExpanded {
            cell = tableView.dequeueReusableCell(withIdentifier: "appearancesCell")!
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

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var chapterString = ""
        
        if myTableView != nil {
            chapterString = chapterTitles[indexPath.row]
        } else {
            chapterString = chapterAppearances[indexPath.section][indexPath.row]
        }
        
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
        } else {
            var shouldReloadMap = false
            if book != currentBook {
                shouldReloadMap = true
            }
            delegate?.reloadMapTextView?(book: book, chapterIndex: chapterIndex!, shouldToggle: true, shouldReloadMap: shouldReloadMap)
        }
        if myTableView == nil {
            appearanceTableView.deselectRow(at: indexPath, animated: false)
        }
       
    }
    
}

