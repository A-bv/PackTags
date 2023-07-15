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
    
    func apiCallGetIgBusinessId(completion: @escaping (Bool) -> ()) {
        verifyCorrectFbPagesSetup { [weak self] isCorrectSetup in
            self?.verifySetupIgBAndGetIgBId { [weak self] validId in
                if let validId = validId {
                    self?.saveInstagramBusinessAccountID(id: validId)
                    completion(isCorrectSetup)
                } else {
                    completion(false)
                }
            }
        }
    }
}

// MARK: - Logic
extension FBLoginViewModel {
    func savePushedFBLoginButtonOnce() {
        if UserDefaults.standard.object(forKey: "pressedFBLoginButton") == nil {
            UserDefaults.standard.set(true, forKey: "pressedFBLoginButton")
        }
    }
}

// MARK: - Walkthrough
extension FBLoginViewModel {
    private func verifyCorrectFbPagesSetup(completion: @escaping (Bool) -> ()) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            httpMethod: .get)
        
        request.start { connection, result, error in
            if let error = error {
                print("fbPageRequest error:", error)
                return
            }
            
            guard let response = result as? NSDictionary else { return }
            guard let pages = response.value(forKeyPath: "data.name") as? [String] else { return }
            
            if pages.isEmpty {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func verifySetupIgBAndGetIgBId(completion: @escaping (String?) -> ()) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields": "instagram_business_account"],
            httpMethod: .get)
        
        request.start { connection, result, error in
            if let error = error {
                print("igBRequest error:", error)
                return
            }
            
            guard let response = result as? NSDictionary else { return }
            
            if let igBIds = response.value(forKeyPath: "data.instagram_business_account.id") as? [String] {
                completion(igBIds.first)
            } else {
                print("No business account linked or wrong pages selected")
                completion(nil)
            }
        }
    }
}

// MARK: - Saving
extension FBLoginViewModel {
    private func saveInstagramBusinessAccountID(id: String) {
        UserDefaults.standard.set(id, forKey: "IgBId")
    }

    private func saveFBToken(token: FBToken) {
        let tokenString = token.tokenString
        UserDefaults.standard.set(tokenString, forKey: "fbToken")
    }
    
    private func saveCorrectStatus(token: FBToken) {
        UserDefaults.standard.set(token.isValid, forKey: "isCorrectSetup")
    }
}
