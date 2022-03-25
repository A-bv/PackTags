//
//  Import.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import FBSDKLoginKit

let apiGph_version = "v13.0" //Api graph version
let fbToken = UserDefaults.standard.string(forKey: "fbToken") ?? ""
let igBId = UserDefaults.standard.string(forKey: "IgBId") ?? ""

#if (arch(arm64) || arch(x86_64))
@available(iOS 13.0, *)

//AnalyticsNew's importation function: Functions for init() {}
extension ANewVCDataSUI {

    //1 local import (called when refreshing data without web)
    func getJsonFromDir () {
        DispatchQueue.main.async {
            guard let jsonData = GetJson.getJsonDataFromDir() else { return } //data
            guard let json = GenericJSONParser.ParseJs2(of: Profile.self, data: jsonData) as? Profile else { return }
     
            self.jsonOfficial = json
            self.processedJson = ProcessJson.processJsApiGraph(decodedJson: json)
            
            //VARR Entry (dir)
            //self.getEngagementVariations(isFromSave: true)
            
            // fill (update)
            self.fillGraphData ()
            self.fillData()
        }
    }
    
    //2 web import
    func getOnlineJsonAPIGraph () {
        GetJson.load_Profile(completion: {
            (json) in
            DispatchQueue.main.async{
                self.jsonOfficial = json
                self.processedJson = ProcessJson.processJsApiGraph(decodedJson: json)
                self.fillGraphData ()
                self.fillData()
                //self.getEngagementVariations(isFromSave: false) //VARR
            }
        })
    }
}
#endif

//AnalyticsOld's importation functions
extension AnalyticsOld {

    //1 local import
    func getJsonFromDir () {
        guard let jsonData = GetJson.getJsonDataFromDir() else { return }   //type data
        guard let json = GenericJSONParser.ParseJs2(of: Profile.self, data: jsonData) as? Profile else { return }

        displayDataComingFromApiGraph(Json: json)
    }
    
    //2 web import
    func getOnlineJsonApiGraphOld () {
        loginSpinner.startAnimating()
        
        GetJson.load_Profile(completion: {
            (Json) in
            DispatchQueue.main.async{
                self.loginSpinner.stopAnimating()
                self.displayDataComingFromApiGraph(Json: Json )
            }
        })
    }
}
