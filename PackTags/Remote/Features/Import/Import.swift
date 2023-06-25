//
//  Import.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

let apiGph_version = "v13.0" //Api graph version
let fbToken = UserDefaults.standard.string(forKey: "fbToken") ?? ""
let igBId = UserDefaults.standard.string(forKey: "IgBId") ?? ""

// Analytics
extension AnalyticsSUIViewModel {
    // 1. local import (called when refreshing data without web)
    func getJsonFromDir () {
        DispatchQueue.main.async { [weak self] in
            guard let jsonData = DocumentDirectory.getJsonDataFromDir() else { return } //data
            guard
                let profileJson = GenericJSONParser.ParseJs(
                    of: Profile.self,
                    data: jsonData) as? Profile
            else { return }
     
            DispatchQueue.main.async{ [weak self] in
                self?.load(profileJson: profileJson)
            }
        }
    }
    
    // 2. Api import
    func getOnlineJsonAPIGraph () {
        ApiService.loadProfileForAnalytics(
            completion: { (profileJson) in
                DispatchQueue.main.async { [weak self] in
                    self?.load(profileJson: profileJson)
                }
            })
    }
    
    private func load(profileJson: Profile) {
        jsonOfficial = profileJson
        processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson)
        // QQQ
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            // self?.processedJson = self?.fakeProcessedJson0()
            //self?.jsonOfficial = nil
            //self?.processedJson = nil
        }*/
        updateData()
    }
    
    private func updateData() {
        fillGraphData()
        fillData()
    }
}

// SmartG
extension SmartGViewModel {
    // 1. Api import
    func fetch(hashtag: String) {
        ApiService.searchHashtag(
            searchedHashtag: hashtag,
            completion: {
                [weak self] (result) in
                guard let result = result as? [DataMedia] else {return}
                self?.dataMedias = result
                self?.processSmartGModel()
            })
        
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}
