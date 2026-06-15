import Foundation
import InstagramGraph

@MainActor
final class FBLoginViewModel {
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let settings: any AppSettingsProtocol
    private let facebookSessionService: any FacebookSessionServicing

    init(
        gateway: any ConnectedInsightsGatewayProtocol,
        settings: any AppSettingsProtocol,
        facebookSessionService: any FacebookSessionServicing = FacebookSessionService()
    ) {
        self.gateway = gateway
        self.settings = settings
        self.facebookSessionService = facebookSessionService
    }

    var hasSeenSetupInfo: Bool {
        settings.setupInfoShown
    }

    func getToken() -> FBToken {
        facebookSessionService.currentToken()
    }

    func setup(with token: FBToken) async throws {
        guard let tokenString = token.tokenString else {
            throw ConnectedInsightsError.missingFacebookToken
        }
        try await gateway.setup(facebookToken: tokenString)
    }

    func markLoginButtonPressed() {
        settings.pressedFBLoginButton = true
    }

    func resetFacebookSession() {
        facebookSessionService.resetSession()
        gateway.reset()
        settings.pressedFBLoginButton = false
        AppLogger.login.info("Facebook SDK session and connected insights setup were reset.")
    }
}
