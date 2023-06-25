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
                DispatchQueue.main.async{ [weak self] in
                    self?.load(profileJson: profileJson)
                }
            })
    }
    
    private func load(profileJson: Profile) {
        jsonOfficial = profileJson
        processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson)
        // QQQ
        // processedJson = fakeProcessedJson()
        updateData()
    }
    
    private func updateData() {
        fillGraphData()
        fillData()
    }
}

// Preview Testing purposes QQQ:
// ***
extension AnalyticsSUIViewModel {
    func fakeProcessedJson () -> TransformedProfileModel {
        TransformedProfileModel(
            usr: "packtags.app",
            isPv: false,
            sum0: Optional(225),
            sum1: Optional(26),
            avg0: Optional("18.8"),
            avg1: Optional("2.2"),
            rates: [Optional(12.0), Optional(23.0), Optional(16.0)],
            pTimes: [Optional(1639268616.0), Optional(1637529580.0), Optional(1636327207.0)],
            avg2: 23.0,
            maxR: 40.0,
            captions: ["A", "B", "C"])
    }
}
// ***


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
