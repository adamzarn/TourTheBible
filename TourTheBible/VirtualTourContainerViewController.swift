//
//  VirtualTourContainerViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 3/14/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import QuartzCore

enum TourState {
    case Collapsed
    case RightPanelExpanded
    case RightPanelWillExpand
}

class VirtualTourContainerViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    var VirtualTourViewController: VirtualTourViewController!
    var rightPanelViewController: VirtualTourPanelViewController?
    var tour: String!
    var addingRightPanel = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VirtualTourViewController = UIStoryboard.VirtualTourViewController()
        VirtualTourViewController.delegate = self
        VirtualTourViewController.tour = tour
        
        centerNavigationController = UINavigationController(rootViewController: VirtualTourViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
    }
    
}

extension VirtualTourContainerViewController: VirtualTourViewControllerDelegate {
    
    func toggleRightPanel() {
        let notAlreadyExpanded = (appDelegate.tourState != .RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addRightPanelViewController() {
        appDelegate.tourState = .RightPanelWillExpand
        addingRightPanel = true
        if (rightPanelViewController == nil) {
            rightPanelViewController = UIStoryboard.rightPanelViewController()
            rightPanelViewController?.chapterAppearances = VirtualTourViewController.chapterAppearances
            rightPanelViewController?.bookAppearances = VirtualTourViewController.bookAppearances
            rightPanelViewController?.tappedLocation = VirtualTourViewController.tappedLocation
            rightPanelViewController?.subtitles = VirtualTourViewController.subtitles
            rightPanelViewController?.delegate = self.VirtualTourViewController
            
            addChildSidePanelController(sidePanelController: rightPanelViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: VirtualTourPanelViewController) {
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
            appDelegate.tourState = .RightPanelExpanded
            showShadowForCenterViewController(shouldShowShadow: true)
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width/2)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.appDelegate.tourState = .Collapsed
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
    
    class func rightPanelViewController() -> VirtualTourPanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "VirtualTourPanelViewController") as? VirtualTourPanelViewController
    }
    
    class func VirtualTourViewController() -> VirtualTourViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "VirtualTourViewController") as? VirtualTourViewController
    }
    
}
