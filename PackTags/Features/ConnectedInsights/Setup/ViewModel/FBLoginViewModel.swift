import Foundation
import InstagramGraph

@MainActor
final class FBLoginViewModel {
    /// What the screen should do when it appears.
    enum AppearAction {
        case showSetupInfo
        case validateExistingSession
        case idle
    }

    /// The outcome of attempting Graph setup with the current Facebook token.
    enum SetupResult: Equatable {
        case connected
        /// The token was missing or rejected; the session has been cleared, so the
        /// user can simply log in again.
        case sessionExpired
        case failed(message: String)
    }

    /// Business permissions require a classic access token — Limited Login only yields
    /// an OIDC token the Instagram Graph calls can't use.
    let loginPermissions = [
        "instagram_basic",
        "pages_show_list",
        "instagram_manage_insights",
        "business_management",
    ]

    private let gateway: any ConnectedInsightsGatewayProtocol
    private let settings: any AppSettingsProtocol
    private let facebookSessionService: any FacebookSessionServiceProtocol

    var hasSeenSetupInfo: Bool { settings.setupInfoShown }

    init(
        gateway: any ConnectedInsightsGatewayProtocol,
        settings: any AppSettingsProtocol,
        facebookSessionService: any FacebookSessionServiceProtocol = FacebookSessionService()
    ) {
        self.gateway = gateway
        self.settings = settings
        self.facebookSessionService = facebookSessionService
    }

    func onAppear() -> AppearAction {
        guard settings.setupInfoShown else { return .showSetupInfo }
        return facebookSessionService.currentToken().tokenString == nil ? .idle : .validateExistingSession
    }

    /// Establishes/validates the Graph setup with the current Facebook token and
    /// classifies the outcome. On a recoverable auth failure the stale session is
    /// cleared so the next login starts clean — no manual "reset" needed.
    func validateSetup(markLoginAttempt: Bool = false) async -> SetupResult {
        if markLoginAttempt { markLoginButtonPressed() }

        let token = facebookSessionService.currentToken()
        AppLogger.login.info("Setup token check: \(token.diagnostic, privacy: .public)")

        guard let tokenString = token.tokenString else {
            resetFacebookSession()
            return .sessionExpired
        }

        do {
            try await gateway.setup(facebookToken: tokenString)
            return .connected
        } catch {
            AppLogger.login.info("Setup failed: \(error.localizedDescription, privacy: .public)")
            if Self.isRecoverableAuthFailure(error) {
                resetFacebookSession()
                return .sessionExpired
            }
            return .failed(message: error.localizedDescription)
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

    /// True when the failure means the Facebook token is invalid / expired / missing —
    /// recoverable by logging in again, as opposed to a network or wrong-account error.
    static func isRecoverableAuthFailure(_ error: Error) -> Bool {
        if case ConnectedInsightsError.missingFacebookToken = error { return true }
        guard let graphError = error as? InstagramGraphServiceError else { return false }
        switch graphError {
        case let .graphHTTPError(_, body):
            return body.contains("OAuthException") || body.contains("\"code\":190")
        case let .missingCredentials(hasToken, _):
            return !hasToken
        default:
            return false
        }
    }
}
