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
        
        //Keep Launch screen for a second
        Thread.sleep(forTimeInterval: 0.5)
        
        //Load samples
        if Core.shared.isNewUser() {
            seedData()
        }
        
        setupAppearance()
        //coredatavisu()
        
        //Fb login
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        //Storekit (app review)
        StoreKitHelper.incrementNumberOftimesLaunched()

        return true
    }
    
    //Fb login
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool { ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] ) }

    // MARK: - Style
    func setupAppearance() {
        let color = customPurple
        
        //view
        UITextView.appearance().tintColor = color
        UITextField.appearance().tintColor = color
        UISearchBar.appearance().tintColor = color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = color
        
        UITableView.appearance().tintColor = color //Cell buttons
        
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Core Data data visualisation
    func coredatavisu(){ // custom func
        let link = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!
        
        print(
            """
            External device Core Data db: xcode>window>devices - select app>download - right click>show package content>application support
            
            iOS simulator Core Data db: Finder>, press "CMD+N", "CMD + Shift + G", Paste:
            
            \(link)
            
            open .sqlite with 'DB browser for SQLite' or press "CMD + shift + ." in the application support folder to reveal external storage images
            """
        )
    }
        
    func seedData() {
        let fm = FileManager.default
        
        //Destination URL of application folder
        let libURL = fm.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let destFolder = libURL.appendingPathComponent("Application Support").path
        //Or
        //let l1 = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!
        //
        
        //Start URL of Testt
        let folderPath = Bundle.main.resourceURL!.appendingPathComponent("SeedData").path
        
        let fileManager = FileManager.default
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            if let applicationSupportURL = urls.last {
                do{
                    try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
                }
                catch{
                    print(error)
                }
            }
        
        copyFiles(pathFromBundle: folderPath, pathDestDocs: destFolder)
        
    }
  

    func copyFiles(pathFromBundle : String, pathDestDocs: String) {
    
        
        let fm = FileManager.default
        do {
            let filelist = try fm.contentsOfDirectory(atPath: pathFromBundle)
            let fileDestList = try fm.contentsOfDirectory(atPath: pathDestDocs)

            for filename in fileDestList {
                try FileManager.default.removeItem(atPath: "\(pathDestDocs)/\(filename)")
            }
            
            for filename in filelist {
                try? fm.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("Error info: \(error)")
            
        }
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
}


// MARK: - Safe area properties (added for PackTags)
extension UIApplication {
    
    var statusBarUIView: UIView? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let tag = 38482
        if let statusBar = keyWindow?.viewWithTag(tag) {
            return statusBar
        } else {
            guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.tag = tag
            keyWindow?.addSubview(statusBarView)
            return statusBarView
        }
    }
}
