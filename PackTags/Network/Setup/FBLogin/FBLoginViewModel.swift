//
//  FBLoginViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import FBSDKLoginKit

final class FBLoginViewModel {
    func getToken() -> FBToken {
        let token = FBToken()
        saveCorrectStatus(token: token)
        saveFBToken(token: token)
        return token
    }
    
    func apiCallGetIgBusinessId(Completion completed: @escaping (Bool) -> ()) {
        verifySetupFbPages(Completion: { [weak self] isCorrectSetup in
            self?.verifySetupIgBAndGetIgBId(Completion: { [weak self] validId in
                if let validId {
                    self?.saveInstagramBusinessAccountID(id: validId)
                    completed(isCorrectSetup)
                } else {
                    completed(false)
                }
            })
        })
    }

    private func verifySetupFbPages (Completion correctPagesSetup: @escaping (Bool) -> ()) {
        // 0. Fb acc gives a token
        // Request 1. Get facebook business page of the facebook account
        let fbPageRequest = GraphRequest(graphPath: "/me/accounts", httpMethod: .get)
        
        fbPageRequest.start(
            completionHandler: { connection, result, error in
            
            if let error = error {
                print("fbPageRequest error :", error)
                return
            }
            
            guard let response1 = result as? NSDictionary else { return } //
                
            //id page fb packtags.app 107298991584829
            // ----- CAUTION ----- only works with one associated page (takes the first in array)
            guard let pages = (response1.value(forKeyPath: "data.name") as? [String]) else { return }
            
            if pages.isEmpty { // Exit if no IGPro or wrong linked FB page(s)
                correctPagesSetup(false)
            }
            // ----- CAUTION -----
            
            correctPagesSetup(true)
        })
    }
    
    private func verifySetupIgBAndGetIgBId (Completion validId: @escaping ((String?) -> ())){
        
        // Required: Fb acc + Fb business page + IG Business or creator
        let igBRequest = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields":"instagram_business_account"],
            httpMethod: .get)
        
        igBRequest.start(
            completionHandler: { connection, result, error in
                
                if let error = error {
                    print("igBRequest error :", error)
                    return
                }
                
                guard let response2 = result as? NSDictionary else { return } //
                
                
                if let igBIds = response2.value(forKeyPath: "data.instagram_business_account.id") as? [String] {
                    if igBIds.count >= 1 {
                        validId(igBIds[0])
                    } else {
                        validId(nil)
                    }
                } else {
                    print("No business account linked or wrong pages selected")
                    validId(nil)
                }
            })
    }
}

// MARK: - Logic
extension FBLoginViewModel {
    func savePushedFBLoginButtonOnce() {
        if UserDefaults.standard.object(forKey: "pressedFBLoginButton") == nil {
            UserDefaults.standard.set(true, forKey: "pressedFBLoginButton")
        }
    }
    
    private func saveInstagramBusinessAccountID(id: String) {
        UserDefaults.standard.set(id, forKey: "IgBId")
    }
}

// MARK: - Logic
extension FBLoginViewModel {
    func saveFBToken (token: FBToken) {
        let token = token.tokenString
        UserDefaults.standard.set( token, forKey: "fbToken")
    }
    
    func saveCorrectStatus (token: FBToken) {
        if token.isValid {
            UserDefaults.standard.set(true, forKey: "isCorrectSetup")
        } else {
            UserDefaults.standard.set(false, forKey: "isCorrectSetup")
        }
    }
}
