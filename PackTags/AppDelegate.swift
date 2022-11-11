//
//  AppDelegate.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Launch screen visible for a second
        Thread.sleep(forTimeInterval: 0.5)
        
        //Load samples
        if Core.shared.isNewUser() { seedData() }
        
        setupAppearance()
        //coredatavisu()
        
        //Fb login
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Storekit (app review)
        StoreKitHelper.incrementNumberOftimesLaunched()

        return true
    }
    
    // MARK: - Fb login
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])}

    // MARK: - Style
    func setupAppearance() {
        let color = customPurple
        UITextView.appearance().tintColor = color
        UITextField.appearance().tintColor = color
        UISearchBar.appearance().tintColor = color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = color
        UITableView.appearance().tintColor = color //Cell buttons
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "PackTags"
        var container: NSPersistentContainer!
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var dataController = DataController()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Core Data data visualisation
    func coredatavisu(){ // custom func
        let link = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!
        print(
            """
            External device Core Data db:
            go xcode>window>devices
            select app>download
            right click "show package" then content>application support
            
            iOS simulator Core Data db:
            go Finder,
            press "CMD+N",
            press "CMD + Shift + G",
            Paste: \(link)
            
            open .sqlite with 'DB browser for SQLite'
            or press "CMD + shift + ." in the application support folder
            to reveal external storage images
            """
        )
    }

    //Localize: https://www.youtube.com/watch?v=WSI_LS3Yq8I Change simulator language at 5:55
}
