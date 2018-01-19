//
//  SidePanelViewController.swift
//  TourTheBible
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
    
    let books = Books.books
    let bibles = ["King James Version", "World English Bible"]
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var booksButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    var selectedBible: String?
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @IBOutlet var rightView: UIView!
    @IBOutlet weak var appearanceTableView: UITableView!
    @IBOutlet weak var translationTableView: UITableView!
    
    @IBOutlet weak var myTableView: UITableView!
    var chapterTitles: [String] = []
    var chapterAppearances: [[Chapter]] = []
    var tappedLocation: String = ""
    var currentBook: String = ""
    var delegate: SidePanelViewControllerDelegate?
    
    override func viewDidLoad() {
        
        selectedBible = defaults.value(forKey: "selectedBible") as? String
        
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
        
        let offset = CGFloat(80.0)
        let height1 = (height-offset)*1/4
        let height2 = (height-offset)*3/4
        
        if self.appDelegate.currentState == .LeftPanelWillExpand {
            translationTableView.frame = CGRect(x: 0.0,y: offset, width: width/2,height: height1)
            myTableView.frame = CGRect(x: 0.0,y: offset + height1, width: width/2,height: height2)
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
            return chapterAppearances.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if appDelegate.currentState == .LeftPanelExpanded {
            if tableView == myTableView {
                return "Chapters"
            } else {
                return "Translations"
            }
        } else if appDelegate.currentState == .RightPanelExpanded {
             return (chapterAppearances[section][0]).book
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appDelegate.currentState == .LeftPanelExpanded {
            if tableView == myTableView {
                return chapterTitles.count
            } else {
                return 2
            }
        } else if appDelegate.currentState == .RightPanelExpanded {
            return chapterAppearances[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = CustomTableViewCell()
        
        if appDelegate.currentState == .LeftPanelExpanded {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "chaptersCell") as! CustomTableViewCell
            
            if tableView == myTableView {
                cell.textLabel?.text = chapterTitles[indexPath.row]
            } else {
                cell.textLabel?.text = bibles[indexPath.row]
                if bibles[indexPath.row] == selectedBible {
                    cell.accessoryType = .checkmark
                }
            }
            cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
            
        } else if appDelegate.currentState == .RightPanelExpanded {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "appearancesCell") as! CustomTableViewCell
            let currentChapter = chapterAppearances[indexPath.section][indexPath.row]
            cell.textLabel?.text = currentChapter.book + " " + String(currentChapter.chapterNumber)
            cell.textLabel?.font = UIFont(name: "Papyrus", size: 18.0)
        }
        return cell
    }
    
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView != translationTableView {
            
            var chapterString = ""
            
            if myTableView != nil {
                chapterString = chapterTitles[indexPath.row]
            } else {
                let currentChapter = chapterAppearances[indexPath.section][indexPath.row]
                chapterString = currentChapter.book + " " + String(currentChapter.chapterNumber)
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
                tableView.deselectRow(at: indexPath, animated: true)
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
            
        } else {
            
            UserDefaults.standard.set(bibles[indexPath.row], forKey: "selectedBible")
            selectedBible = bibles[indexPath.row]
            
            delegate?.reloadMapTextView?(book: appDelegate.lastBook, chapterIndex: appDelegate.lastChapter, shouldToggle: true, shouldReloadMap: false)
            
        }
        
    }
    
}

class CustomTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.frame.size.width
        let height = self.frame.size.height
        self.textLabel?.frame = CGRect(x: 20.0, y: height/3.5, width: width - 65.0, height: height/2)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.minimumScaleFactor = 0.5
    }
    
}

