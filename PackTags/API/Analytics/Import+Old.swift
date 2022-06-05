//
//  Import+.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//AnalyticsOld's importation functions
extension AnalyticsOld {

    //1 local import
    func getJsonFromDir () {
        guard let jsonData = GetJson.getJsonDataFromDir() else { return }   //type data
        guard let json = GenericJSONParser.ParseJs(of: Profile.self, data: jsonData) as? Profile else { return }

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
