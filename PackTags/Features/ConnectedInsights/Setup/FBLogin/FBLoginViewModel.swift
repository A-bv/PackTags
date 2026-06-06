//
//  FBLoginViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import FBSDKLoginKit

final class FBLoginViewModel {
    private var settings: any ConnectedInsightsSettingsProtocol

    init(settings: any ConnectedInsightsSettingsProtocol = UserDefaultsAppSettings()) {
        self.settings = settings
    }

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

// MARK: - Walkthrough
extension FBLoginViewModel {
    private func verifyCorrectFbPagesSetup(completion: @escaping (Bool) -> ()) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            httpMethod: .get)
        
        request.start { [weak self] connection, result, error in
            self?.handleCorrectFbPagesSetupResponse(connection, result, error, completion: completion)
        }
    }
    
    private func verifySetupIgBAndGetIgBId(completion: @escaping (String?) -> ()) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields": "instagram_business_account"],
            httpMethod: .get)
        
        request.start { [weak self] connection, result, error in
            self?.handleSetupIgBResponse(connection, result, error, completion: completion)
        }
    }
}

extension FBLoginViewModel {
    private func handleCorrectFbPagesSetupResponse(
        _ connection: GraphRequestConnection?,
        _ result: Any?,
        _ error: (any Error)?,
        completion: @escaping (Bool) -> ()
    ) {
        let key = "data.name"
        if let error = error {
            print("Error during Facebook page request:", error)
            return
        }

        guard let response = result as? NSDictionary else {
            return
        }

        guard let pages = response.value(forKeyPath: key) as? [String] else {
            return
        }

        completion(!pages.isEmpty)
    }

    private func handleSetupIgBResponse(
        _ connection: GraphRequestConnection?,
        _ result: Any?,
        _ error: Error?,
        completion: @escaping (String?) -> ()
    ) {
        let key = "data.instagram_business_account.id"
        if let error = error {
            print("igBRequest error:", error)
            return
        }
        
        guard let response = result as? NSDictionary else {
            return
        }
        
        if let igBIds = response.value(forKeyPath: key) as? [String] {
            completion(igBIds.first)
        } else {
            print("No business account linked or wrong pages selected")
            completion(nil)
        }
    }
}

// MARK: - Saving
extension FBLoginViewModel {
    private func saveInstagramBusinessAccountID(id: String) {
        settings.instagramBusinessAccountId = id
    }

    private func saveFBToken(token: FBToken) {
        let tokenString = token.tokenString
        settings.facebookToken = tokenString
    }
    
    private func saveCorrectStatus(token: FBToken) {
        settings.isCorrectSetup = token.isValid
    }

    func savePushedFBLoginButtonOnce() {
        if !settings.pressedFacebookLoginButton {
            settings.pressedFacebookLoginButton = true
        }
    }
}
