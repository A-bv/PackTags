//
//  FBLoginViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import InstagramGraph

@MainActor
final class FBLoginViewModel {
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let facebookSessionService: any FacebookSessionServicing

    private enum UserDefaultsKey {
        static let pressedFBLoginButton = "pressedFBLoginButton"
    }

    init(
        gateway: any ConnectedInsightsGatewayProtocol,
        facebookSessionService: any FacebookSessionServicing = FacebookSessionService()
    ) {
        self.gateway = gateway
        self.facebookSessionService = facebookSessionService
    }

    func getToken() -> FBToken {
        facebookSessionService.currentToken()
    }

    func setupWithToken(_ token: FBToken, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let tokenString = token.tokenString else {
            completion(.failure(ConnectedInsightsError.missingFacebookToken))
            return
        }
        Task {
            do {
                try await gateway.setup(facebookToken: tokenString)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func savePushedFBLoginButtonOnce() {
        let key = UserDefaultsKey.pressedFBLoginButton
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    func resetFacebookSession() {
        facebookSessionService.resetSession()
        gateway.reset()
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.pressedFBLoginButton)
        print("[ConnectedInsights][Login] Facebook SDK session and connected insights setup were reset.")
    }
}
