//
//  ContainerViewController.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 12/2/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

class ContainerViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    var MapTextViewController: MapTextViewController!
    //var currentState: SlideOutState = .BothCollapsed {
    //    didSet {
    //        let shouldShowShadow = currentState != .BothCollapsed
    //        showShadowForCenterViewController(shouldShowShadow: shouldShowShadow)
    //    }
    //}
    var leftViewController: SidePanelViewController?
    var rightViewController: SidePanelViewController?
    var book: String?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapTextViewController = UIStoryboard.MapTextViewController()
        MapTextViewController.delegate = self
        MapTextViewController.book = book!
        
        centerNavigationController = UINavigationController(rootViewController: MapTextViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
    }
    
}

extension ContainerViewController: MapTextViewControllerDelegate {
    
    func toggleLeftPanel() {
        appDelegate.expandingPanel = "left"
        let notAlreadyExpanded = (appDelegate.currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
        appDelegate.expandingPanel = "right"
        let notAlreadyExpanded = (appDelegate.currentState != .RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController?.chapterTitles = MapTextViewController.chapterTitles
            leftViewController?.delegate = self.MapTextViewController
            
            addChildSidePanelController(sidePanelController: leftViewController!)
        }
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightViewController()
            rightViewController?.chapterTitles = MapTextViewController.chapterTitles
            rightViewController?.delegate = self.MapTextViewController
            
            addChildSidePanelController(sidePanelController: rightViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            appDelegate.currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width/2)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.appDelegate.currentState = .BothCollapsed
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            appDelegate.currentState = .RightPanelExpanded
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width/2)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.appDelegate.currentState = .BothCollapsed
                self.rightViewController!.view.removeFromSuperview()
                self.rightViewController = nil;
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
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    
    class func rightViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? SidePanelViewController
    }
    
    class func MapTextViewController() -> MapTextViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MapTextViewController") as? MapTextViewController
    }
    
}
