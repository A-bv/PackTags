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
