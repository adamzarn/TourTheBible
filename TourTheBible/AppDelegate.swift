//
//  AppDelegate.swift
//  TourTheBible
//
//  Created by Adam Zarn on 9/12/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import StoreKit
import MapKit
import youtube_ios_player_helper
import Firebase
import AVFoundation
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability: Reachability!
    var products = [SKProduct]()
    var chapterIndex: Int = 1
    var videoLibrary: [String: [Video]] = [:]
    var myMapView: MKMapView!
    var myYouTubePlayer: YTPlayerView!
    var currentState: SlideOutState = .BothCollapsed
    var glossaryState: SlideState = .Collapsed
    var tourState: TourState = .Collapsed
    var options: NSDictionary?
    var tabBarHeight: CGFloat?
    var tbc: MainTabBarController?
    var lastBook = "Genesis"
    var lastChapter = 1
    var pool: AWSCognitoIdentityUserPool?
    
    var loginViewController: LoginViewController?
    var currentlyLoggedIn: Bool = false
    var virtualTourTableViewController: VirtualTourTableViewController?
    var accountDetailViewController: AccountDetailViewController?
    var navigationController: UINavigationController?
    var storyboard: UIStoryboard?
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    
    //“‘’”
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        
        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)
        
        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: nil,
                                                                        poolId: CognitoIdentityUserPoolId)
        
        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        // fetch the user pool client we initialized in above step
        let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        pool.delegate = self
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        let defaults = UserDefaults.standard
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let currentVersion = defaults.value(forKey: "currentVersion") as? String
            if version != currentVersion {
                defaults.set(version, forKey: "currentVersion")
            }
        }
        
        if defaults.bool(forKey: "hasBeenLaunched") == true {
            print("has already been launched")
        } else {
            defaults.setValue("King James Version", forKey: "selectedBible")
            defaults.setValue(true, forKey: "hasBeenLaunched")
        }
        
        FIRApp.configure()
        
        myMapView = MKMapView()
        myYouTubePlayer = YTPlayerView()
        
        autoSave(delayInSeconds: 5)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Papyrus", size: 9)!], for: .normal)
        
        let textTitleOptions: [String : Any] = [
            NSFontAttributeName: UIFont(name: "Papyrus", size: 21)!,
            NSForegroundColorAttributeName : UIColor.white,
        ]
        UINavigationBar.appearance().titleTextAttributes = textTitleOptions
        UINavigationBar.appearance().barTintColor = UIColor(red: 28.0/255.0, green: 62.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        UIApplication.shared.statusBarStyle = .default
        
        do {
            reachability = try Reachability()
        } //catch {
        //print("Unable to create Reachability")
        //}
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(note:)), name: ReachabilityChangedNotification,object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
    }

    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AJZ.WalkThroughTheBible" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func autoSave(delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            saveContext()
            
            let time = DispatchTime.now() + .seconds(delayInSeconds)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
            }
            
        }
    }
    
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {

    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        if (self.navigationController == nil) {
            self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController
        }

        self.loginViewController = self.navigationController?.viewControllers[0] as? LoginViewController
        self.loginViewController?.virtualToursDelegate = virtualTourTableViewController
        self.loginViewController?.accountDetailDelegate = accountDetailViewController
        self.loginViewController?.currentlyLoggedIn = currentlyLoggedIn

        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if (!self.navigationController!.isViewLoaded
                || self.navigationController!.view.window == nil) {
                self.window?.rootViewController?.present(self.navigationController!,
                                                         animated: true,
                                                         completion: nil)
            }

        }
        return self.loginViewController!
    }

    func startRememberDevice() -> AWSCognitoIdentityRememberDevice {
        return self
    }
}

// MARK:- AWSCognitoIdentityRememberDevice protocol delegate

extension AppDelegate: AWSCognitoIdentityRememberDevice {
    
    func getRememberDevice(_ rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>) {
        self.rememberDeviceCompletionSource = rememberDeviceCompletionSource
        DispatchQueue.main.async {
            // dismiss the view controller being present before asking to remember device
            self.window?.rootViewController!.presentedViewController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Remember Device",
                                                    message: "Do you want to remember this device?.",
                                                    preferredStyle: .actionSheet)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: false)
            })
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
