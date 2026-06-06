//
//  StoreKitHelper.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/08/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import StoreKit

//Storekit (app review)
struct StoreKitHelper {
    private enum Constants {
        static let limitTimesLaunched: Int = 7
        static let timesLaunched: String = "numberOfTimesLaunched"
    }
    
    static func displayStoreKit() {
        //Current build
        guard let currentBuild = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            return
        }
        
        //Current version
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
           return
        }
        
        //Get saved previous build and version
        let lastBuildPromptedForReview = UserDefaults.standard.string(forKey: "lastBuild")
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersion")
        
        //Exit if app have not been updated
        guard (currentVersion != lastVersionPromptedForReview || currentBuild != lastBuildPromptedForReview) else {return}
        
        //Get number of times launched
        let numberOfTimesLaunched = UserDefaults.standard.integer(forKey: Constants.timesLaunched)
        
        //Enter if over 10th launch
        if numberOfTimesLaunched > Constants.limitTimesLaunched {
            
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            
            UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
        
            UserDefaults.standard.set(currentBuild, forKey: "lastBuild")
        }
    }
    
    static func incrementNumberOftimesLaunched() {
        let newValue = UserDefaults.standard.integer(forKey: Constants.timesLaunched) + 1
        UserDefaults.standard.set(newValue, forKey:  Constants.timesLaunched)
    }
}
