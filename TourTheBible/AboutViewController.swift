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

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var rawText: String = ""
    var aboutText: NSString = ""
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        
        let path = Bundle.main.path(forResource: "About", ofType: "txt")
        
        do {
            rawText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {
        }
        
        myLabel.text = rawText
        
    }
    
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setToRecipients(["adam.zarn@my.wheaton.edu"])
            vc.setSubject("Tour The Bible")
            
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func patreonButtonPressed(_ sender: Any) {
        let url = URL(string: "https://www.patreon.com/adamzarn")!
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
}
