//
//  AboutViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 11/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    var rawText: String = ""
    var aboutText: NSString = ""
    @IBOutlet weak var myTextView: UITextView!
    
    override func viewDidLoad() {
        
        myTextView.delegate = self
        
        let path = Bundle.main.path(forResource: "About", ofType: "txt")
        
        do {
            rawText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {
        }
        
        aboutText = rawText as NSString
        
        let attributedText = NSMutableAttributedString(string: rawText)
        let allRange = (aboutText as NSString).range(of: rawText)
        let range = (aboutText as NSString).range(of: "email")
        attributedText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize:16.0), range: allRange)
        attributedText.addAttribute(NSLinkAttributeName, value: "email", range: range)
        
        myTextView.attributedText = attributedText
        myTextView.isScrollEnabled = false
        myTextView.isEditable = false
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setToRecipients(["adam.zarn@my.wheaton.edu"])
            vc.setSubject("Walk Through The Bible")
            
            self.present(vc, animated: false, completion: nil)
            
            return true
            
        } else {
            return false
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
