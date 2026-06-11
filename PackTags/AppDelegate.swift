//
//  AppDelegate.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !UserDefaultsAppSettings().hasSeenOnboarding { seedData() }

        setupAppearance()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

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

}
