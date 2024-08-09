//
//  AppDelegate.swift
//  Makeda
//
//  Created by Brian on 2017/7/12.
//  Copyright © 2017年 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var backgroundTask:UIBackgroundTaskIdentifier! = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-3903928830427305~3738067320")
        //GADMobileAds.sharedInstance

        // Override point for customization after application launch.
        // 建立一個 UIWindow
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // 設置底色
        self.window!.backgroundColor = UIColor.white

        //DBprepare()

        // 設置根視圖控制器
        self.window!.rootViewController = TabBarController()
        
        // 將 UIWindow 設置為可見的
        self.window!.makeKeyAndVisible()
        mapServices()
        return true
    }
    
    func DBprepare()
    {
        let db:DB_Access? = DB_Access()
        //db!.db_cleanup()
        db!.default_setup()
    }
    
    func TabBarController() -> UITabBarController {
        let SettingViewCtrl = SettingViewController()
        let myTabBarCtrl = UITabBarController()
        let AddViewCtrl = AddViewController()
        let DashViewCtrl = DashViewController()
        let NotifViewCtrl = NotifViewController()
        let nvHome = UINavigationController(rootViewController: AddViewCtrl)
        nvHome.navigationBar.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 1)
        
        // 設置標籤列
        // 使用 UITabBarController 的屬性 tabBar 的各個屬性設置
        myTabBarCtrl.tabBar.backgroundColor = UIColor.clear
        
        myTabBarCtrl.viewControllers = [
            SettingViewCtrl,
            nvHome,
            DashViewCtrl,
            NotifViewCtrl
        ]
        
        let TabSet = myTabBarCtrl.tabBar.items![0]
        TabSet.image = UIImage(named: "setting@x3")
        TabSet.title = "設定"
        
        let TabAdd = myTabBarCtrl.tabBar.items![1]
        TabAdd.image = UIImage(named: "plus@x3")
        TabAdd.title = "新增"
        
        let TabDash = myTabBarCtrl.tabBar.items![2]
        TabDash.image = UIImage(named: "iconfinder_dash.png")
        TabDash.title = "私房手冊"
        
        let TabNotif = myTabBarCtrl.tabBar.items![3]
        TabNotif.image = UIImage(named: "message@x3")
        TabNotif.title = "訊息"
        
        myTabBarCtrl.selectedIndex = 2
 
        return myTabBarCtrl
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        /*
        if self.backgroundTask != nil {
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
        
        self.backgroundTask = application.beginBackgroundTask(
            expirationHandler: { () -> Void in
            //application.endBackgroundTask(self.backgroundTask)
            //self.backgroundTask = UIBackgroundTaskInvalid
                
            })
         */
        //BackgroundWork
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        CoreDataStack.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Makeda")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // iOS 9 and below
    @available(iOS 9.3, *)
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    @available(iOS 9.3, *)
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        var modelURL = Bundle.main.url(forResource: "Makeda", withExtension: "momd")!
        modelURL.appendPathComponent("Makeda.mom")
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    @available(iOS 9.3, *)
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Makeda.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            //try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            let moption = [NSMigratePersistentStoresAutomaticallyOption: true,NSInferMappingModelAutomaticallyOption: true]

            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: moption)
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
    
    @available(iOS 9.3, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    @available(iOS 9.3, *)
    static func getEntity<T: NSManagedObject> () -> T {
        if #available(iOS 10, *) {
            let obj = T(context: CoreDataStack.managedObjectContext)
            return obj
        } else {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: NSStringFromClass(T.self), in: CoreDataStack.managedObjectContext) else {
                fatalError("Core Data entity name doesn't match.")
            }
            let obj = T(entity: entityDescription, insertInto: CoreDataStack.managedObjectContext)
            return obj
        }
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions 
            // iOS 9.0 and below - however you were previously handling it
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
    }
}

