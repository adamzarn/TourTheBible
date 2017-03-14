//
//  SlidingViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/13/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideState {
    case Collapsed
    case RightPanelExpanded
    case RightPanelWillExpand
}

class SlidingViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    var GlossaryViewController: GlossaryViewController!
    var rightPanelViewController: RightPanelViewController?
    var addingRightPanel = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlossaryViewController = UIStoryboard.GlossaryViewController()
        GlossaryViewController.delegate = self
        
        centerNavigationController = UINavigationController(rootViewController: GlossaryViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
    }
    
}

extension SlidingViewController: GlossaryViewControllerDelegate {
    
    func toggleRightPanel() {
        let notAlreadyExpanded = (appDelegate.glossaryState != .RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addRightPanelViewController() {
        appDelegate.glossaryState = .RightPanelWillExpand
        addingRightPanel = true
        if (rightPanelViewController == nil) {
            rightPanelViewController = UIStoryboard.rightPanelViewController()
            rightPanelViewController?.chapterAppearances = GlossaryViewController.chapterAppearances
            rightPanelViewController?.bookAppearances = GlossaryViewController.bookAppearances
            rightPanelViewController?.tappedLocation = GlossaryViewController.tappedLocation
            rightPanelViewController?.subtitles = GlossaryViewController.subtitles
            rightPanelViewController?.delegate = self.GlossaryViewController
            
            addChildSidePanelController(sidePanelController: rightPanelViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: RightPanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        
        if addingRightPanel {
            sidePanelController.view.frame.origin.x = centerNavigationController.view.frame.width/2
        }
        addingRightPanel = false
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            appDelegate.glossaryState = .RightPanelExpanded
            showShadowForCenterViewController(shouldShowShadow: true)
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width/2)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.appDelegate.glossaryState = .Collapsed
                self.rightPanelViewController!.view.removeFromSuperview()
                self.rightPanelViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func rightPanelViewController() -> RightPanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "RightPanelViewController") as? RightPanelViewController
    }
    
    class func GlossaryViewController() -> GlossaryViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "GlossaryViewController") as? GlossaryViewController
    }
    
}

