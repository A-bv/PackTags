//
//  FBLoginViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import InstagramGraph

final class FBLoginViewModel {
    private var settings: any ConnectedInsightsSettingsProtocol
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let facebookSessionService: any FacebookSessionServicing

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        gateway: any ConnectedInsightsGatewayProtocol = ConnectedInsightsGateway(),
        facebookSessionService: any FacebookSessionServicing = FacebookSessionService()
    ) {
        self.settings = settings
        self.gateway = gateway
        self.facebookSessionService = facebookSessionService
    }

    func getToken() -> FBToken {
        facebookSessionService.currentToken()
    }

    func setupWithToken(_ token: FBToken, completion: @escaping (Bool) -> Void) {
        guard let tokenString = token.tokenString else {
            completion(false)
            return
        }
        gateway.setup(facebookToken: tokenString, completion: completion)
    }

    func savePushedFBLoginButtonOnce() {
        if !settings.pressedFacebookLoginButton {
            settings.pressedFacebookLoginButton = true
        }
    }

    func resetFacebookSession() {
        facebookSessionService.resetSession()
        gateway.reset()
        settings.pressedFacebookLoginButton = false
        print("[ConnectedInsights][Login] Facebook SDK session and connected insights setup were reset.")
    }
}
