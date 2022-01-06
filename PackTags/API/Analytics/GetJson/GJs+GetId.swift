//
//  GJs+GetIgBId.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 06/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import FBSDKLoginKit

extension GetJson {
    
    //PLLL BLOCKAGE
    class func getIgBId (Completion block: @escaping ((String) -> ())){
        
        // Required: Fb acc + Fb business page + IG Business or creator
        // 0. Fb acc gives a token
        
        // Request 1. Get facebook business page of the facebook account
        let fbPageRequest = GraphRequest(graphPath: "/me/accounts", httpMethod: .get)
    
        fbPageRequest.start(completion: {connection,result,error in
            
            if let error = error {
                print("fbPageRequest error :", error)
                return
            }

            guard let response1 = result as? NSDictionary else {
                return } //
            
            // ----- CAUTION ----- only works with one associated page (takes the first in array)
            let pages = (response1.value(forKeyPath: "data.name") as? [String])
            if pages == [] {
                // Exit if no IGPro or wrong linked FB page(s)
                print("No page")
                Utility.setupTroubleShootingAlert(arr: [])
                return
            }
            //let pageId = (response1.value(forKeyPath: "data.id") as? [String])?[0] ?? "n/a"
            // ----- CAUTION -----
            
            // Request 2. Get the business IG account associated to the business page
           let igBRequest = GraphRequest(graphPath: "/me/accounts", parameters: ["fields":"instagram_business_account"], httpMethod: .get)
            
           igBRequest.start(completion: {connection,result,error in
          
               if let error = error {
                   print("igBRequest error :", error)
                   return
               }
               
               guard let response2 = result as? NSDictionary else { return } //
               guard let igBIds = (response2.value(forKeyPath: "data.instagram_business_account.id") as? [String])
               else {
                   //No business account linked
                   Utility.setupTroubleShootingAlert(arr: [])
                   return
               }
               
               if igBIds.count >= 1 {
                   block(igBIds[0])
               } else {
                   return
               }
           })
        })
    }
}






