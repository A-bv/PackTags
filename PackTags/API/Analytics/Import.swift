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

//AnalyticsNew's importation function: Functions for init() {}
extension AnalyticsVCModels {
    //1 local import (called when refreshing data without web)
    func getJsonFromDir () {
        DispatchQueue.main.async {
            guard let jsonData = GetJson.getJsonDataFromDir() else { return } //data
            guard let profileJson = GenericJSONParser.ParseJs(of: Profile.self, data: jsonData) as? Profile else { return }
     
            self.jsonOfficial = profileJson
            self.processedJson = ProcessJson.transform(decodedJson: profileJson)
            
            //VARR Entry (dir)
            // self.getEngagementVariations(isFromSave: true)
            
            // fill (update)
            self.fillGraphData ()
            self.fillData()
        }
    }
    
    //2 web import
    func getOnlineJsonAPIGraph () {
        GetJson.load_Profile(completion: {
            (profileJson) in
            DispatchQueue.main.async{ [weak self] in
                self?.jsonOfficial = profileJson
                self?.processedJson = ProcessJson.transform(decodedJson: profileJson)
                self?.fillGraphData()
                self?.fillData()
                //self.getEngagementVariations(isFromSave: false) //VARR
            }
        })
    }
}
