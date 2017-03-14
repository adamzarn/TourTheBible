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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability!
    var products = [SKProduct]()
    var chapterIndex: Int = 1
    var glossary = [BibleLocation]()
    var videoLibrary: [String: [Video]] = [:]
    var myMapView: MKMapView!
    var myYouTubePlayer: YTPlayerView!
    var currentState: SlideOutState = .BothCollapsed
    var glossaryState: SlideState = .Collapsed
    var options: NSDictionary?
    var tabBarHeight: CGFloat?
    var tbc: MainTabBarController?

    //“‘’”

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let tabBarController = MainTabBarController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let booksVC = storyboard.instantiateViewController(withIdentifier: "BooksNavigationController") as! UINavigationController
        let glossaryVC = SlidingViewController()
        let virtualTourVC = storyboard.instantiateViewController(withIdentifier: "VirtualTourNavigationController") as! UINavigationController
        let biblesVC = storyboard.instantiateViewController(withIdentifier: "BiblesNavigationController") as! UINavigationController
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutNavigationController") as! UINavigationController
        
        tabBarController.viewControllers = [booksVC, glossaryVC, virtualTourVC, biblesVC, aboutVC]
        window?.rootViewController = tabBarController
        
        self.tbc = tabBarController
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        let defaults = UserDefaults.standard
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let currentVersion = defaults.value(forKey: "currentVersion") as? String
            if version != currentVersion {
                preloadData()
                defaults.set(version, forKey: "currentVersion")
            }
        }
        
        FIRApp.configure()
        
        myMapView = MKMapView()
        myYouTubePlayer = YTPlayerView()

        if defaults.bool(forKey: "hasBeenLaunched") == true {
            print("has already been launched")
        } else {
            defaults.setValue("King James Version", forKey: "selectedBible")
            defaults.setValue(true, forKey: "hasBeenLaunched")
        }
        
        let context = self.managedObjectContext
        let request: NSFetchRequest<BibleLocation> = BibleLocation.fetchRequest()
        
        do {
            let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            self.glossary = results as! [BibleLocation]
        } catch let e as NSError {
            print("Failed to retrieve record: \(e.localizedDescription)")
        }

        autoSave(delayInSeconds: 5)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Papyrus", size: 21)!]
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Papyrus", size: 9)!], for: .normal)
        
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
        
        return true
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
    
    func parseCSV(contentsOfURL: NSURL, encoding: String.Encoding, error: NSErrorPointer) -> [(key:String, name:String, lat:Double, long:Double)]? {
        let delimiter = ","
        var items:[(key:String, name:String, lat:Double, long:Double)]?
        
        if let data = NSData(contentsOf: contentsOfURL as URL) {
            if let content = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                items = []
                let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            
                for line in lines {
                    var values:[String] = []
                    values = line.components(separatedBy: delimiter)
                    print(values)
                    if values.count == 4 {
                        let item = (key: values[0], name: values[1], lat: Double(values[2])!, long: Double(values[3])!)
                        items?.append(item)
                    }
                }
            }
        }
        return items
    }
    
    func preloadData () {
        // Retrieve data from the source file
        if let contentsOfURL = Bundle.main.url(forResource:"BibleLocations", withExtension: "csv") {
            
            removeData()
            
            var error:NSError?
            if let items = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, error: &error) {
                let managedObjectContext = self.managedObjectContext
                    for item in items {
                        
                        let bibleLocation = NSEntityDescription.insertNewObject(forEntityName: "BibleLocation", into: managedObjectContext) as! BibleLocation
                        bibleLocation.key = item.key
                        bibleLocation.name = item.name
                        bibleLocation.lat = item.lat
                        bibleLocation.long = item.long
                        
                        saveContext()
                    }
                }
            }

    }
    
    func removeData () {
        //Remove the existing items
        let managedObjectContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BibleLocation")

        var bibleLocations: [BibleLocation]?
        
        do {
            bibleLocations = try managedObjectContext.fetch(fetchRequest) as? [BibleLocation]
        } catch let e as NSError {
            print("Failed to retrieve record: \(e.localizedDescription)")
            return
        }
        for bibleLocation in bibleLocations! {
            print("\(bibleLocation.name) deleted")
            managedObjectContext.delete(bibleLocation)
        }
    }

}
