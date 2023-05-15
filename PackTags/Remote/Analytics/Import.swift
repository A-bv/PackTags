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
            guard let profileJson = GenericJSONParser.ParseJs(
                of: Profile.self,
                data: jsonData) as? Profile else { return }
     
            self?.jsonOfficial = profileJson
            self?.processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson)
            self?.updateData()
        }
    }
    
    // 2. Api import
    func getOnlineJsonAPIGraph () {
        ApiService.loadProfile(
            completion: { (profileJson) in
                DispatchQueue.main.async{ [weak self] in
                    self?.jsonOfficial = profileJson
                    self?.processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson)
                    self?.updateData()
                }
            })
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
        ApiService.igHashtagSearch(
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
