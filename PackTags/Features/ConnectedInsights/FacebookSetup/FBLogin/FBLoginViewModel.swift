//
//  FBLoginViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

final class FBLoginViewModel {
    private var settings: any ConnectedInsightsSettingsProtocol
    private let facebookSetupService: any FacebookSetupServicing
    private let facebookSessionService: any FacebookSessionServicing

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        facebookSetupService: any FacebookSetupServicing = FacebookSetupService(),
        facebookSessionService: any FacebookSessionServicing = FacebookSessionService()
    ) {
        self.settings = settings
        self.facebookSetupService = facebookSetupService
        self.facebookSessionService = facebookSessionService
    }

    func getToken() -> FBToken {
        facebookSessionService.currentToken()
    }
    
    func apiCallGetIgBusinessId(completion: @escaping (Bool) -> ()) {
        facebookSetupService.validateSetup { [weak self] result in
            if let instagramBusinessAccountId = result.instagramBusinessAccountId {
                self?.saveInstagramBusinessAccountID(id: instagramBusinessAccountId)
            }
            self?.saveCorrectStatus(result.isCorrectSetup)
            completion(result.isCorrectSetup)
        }
    }
}

// MARK: - Saving
extension FBLoginViewModel {
    private func saveInstagramBusinessAccountID(id: String) {
        settings.instagramBusinessAccountId = id
    }

    func saveFacebookToken(_ token: FBToken) {
        let tokenString = token.tokenString
        settings.facebookToken = tokenString
    }
    
    private func saveCorrectStatus(_ isCorrectSetup: Bool) {
        settings.isCorrectSetup = isCorrectSetup
    }

    func savePushedFBLoginButtonOnce() {
        if !settings.pressedFacebookLoginButton {
            settings.pressedFacebookLoginButton = true
        }
    }

    func resetFacebookSession() {
        facebookSessionService.resetSession()
        settings.facebookToken = nil
        settings.instagramBusinessAccountId = nil
        settings.isCorrectSetup = false
        settings.pressedFacebookLoginButton = false
        print("[ConnectedInsights][Login] Facebook SDK session and connected insights setup were reset.")
    }
}
