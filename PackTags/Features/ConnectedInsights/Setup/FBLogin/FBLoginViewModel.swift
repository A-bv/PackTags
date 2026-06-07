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

    init(settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings()) {
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

        logSetup("Request /me/accounts")
        
        request.start { [weak self] connection, result, error in
            self?.handleCorrectFbPagesSetupResponse(connection, result, error, completion: completion)
        }
    }
    
    private func verifySetupIgBAndGetIgBId(completion: @escaping (String?) -> ()) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields": "instagram_business_account"],
            httpMethod: .get)

        logSetup("Request /me/accounts fields=instagram_business_account")
        
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
            logSetup("Facebook page request failed: \(error.localizedDescription)")
            completion(false)
            return
        }

        guard let response = result as? NSDictionary else {
            logUnexpectedResult(result, context: "Facebook page request")
            completion(false)
            return
        }

        guard let pages = response.value(forKeyPath: key) as? [String] else {
            logSetup("Facebook page request returned no page names. Response: \(responsePreview(response))")
            completion(false)
            return
        }

        logSetup("Facebook page request returned \(pages.count) page(s).")
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
            logSetup("Instagram business account request failed: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let response = result as? NSDictionary else {
            logUnexpectedResult(result, context: "Instagram business account request")
            completion(nil)
            return
        }
        
        if let igBIds = response.value(forKeyPath: key) as? [String] {
            logSetup("Instagram business account request returned \(igBIds.count) id(s).")
            completion(igBIds.first)
        } else {
            logSetup("No business account linked or wrong pages selected. Response: \(responsePreview(response))")
            completion(nil)
        }
    }

    private func logUnexpectedResult(_ result: Any?, context: String) {
        logSetup("\(context) returned an unexpected result: \(String(describing: result))")
    }

    private func responsePreview(_ response: NSDictionary) -> String {
        if JSONSerialization.isValidJSONObject(response),
           let data = try? JSONSerialization.data(withJSONObject: response, options: [.sortedKeys]),
           let body = String(data: data, encoding: .utf8) {
            return String(body.prefix(1_500))
        }

        return String(String(describing: response).prefix(1_500))
    }

    private func logSetup(_ message: String) {
        print("[ConnectedInsights][Setup] \(message)")
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
