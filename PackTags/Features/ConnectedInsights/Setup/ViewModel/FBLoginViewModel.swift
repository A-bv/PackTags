import Foundation
import InstagramGraph

@Observable
@MainActor
final class FBLoginViewModel {
    /// The outcome of attempting Graph setup with the current Facebook token.
    enum SetupResult: Equatable {
        case connected
        /// The token was missing or rejected; the session has been cleared, so the
        /// user can simply log in again.
        case sessionExpired
        case failed(message: String?)
    }

    /// Business permissions require a classic access token — Limited Login only yields
    /// an OIDC token the Instagram Graph calls can't use.
    let loginPermissions = [
        "instagram_basic",
        "pages_show_list",
        "instagram_manage_insights",
        "business_management",
    ]

    private(set) var isValidating = false
    /// Set when a setup attempt finishes; the view consumes it (alert / dismiss) and
    /// calls `clearResult()`.
    private(set) var result: SetupResult?
    /// True when the latest `.connected` came from an active login (button tap), not a
    /// passive re-validation on appear — so the view confirms with an alert only then.
    private(set) var connectedViaLogin = false
    /// Mirrors the live ATT status (Facebook only issues a Graph-usable token when on).
    private(set) var isTrackingAuthorized: Bool

    private let gateway: any ConnectedInsightsGatewayProtocol
    private let settings: any AppSettingsProtocol
    private let facebookSessionService: any FacebookSessionServiceProtocol
    private let tracking: any AppTrackingAuthorizerProtocol

    var hasSeenSetupInfo: Bool { settings.setupInfoShown }

    init(
        gateway: any ConnectedInsightsGatewayProtocol,
        settings: any AppSettingsProtocol,
        facebookSessionService: any FacebookSessionServiceProtocol = FacebookSessionService(),
        tracking: any AppTrackingAuthorizerProtocol = AppTrackingAuthorizer()
    ) {
        self.gateway = gateway
        self.settings = settings
        self.facebookSessionService = facebookSessionService
        self.tracking = tracking
        self.isTrackingAuthorized = tracking.isAuthorized
    }

    /// Prompts ATT (first time) and validates any existing session.
    func onAppear() async {
        _ = await tracking.requestIfNeeded()
        isTrackingAuthorized = tracking.isAuthorized
        guard facebookSessionService.currentToken().tokenString != nil else { return }
        await validateSetup(markLoginAttempt: false)
    }

    /// Called when the Facebook login button finishes (not on cancel).
    func didCompleteLogin(error: Error?) async {
        if let error {
            result = .failed(message: "Facebook Login failed: \(error.localizedDescription)")
            return
        }
        await validateSetup(markLoginAttempt: true)
    }

    /// The toggle can't flip the OS-level ATT decision in-app — FBSDK 17+ derives it
    /// from the system status — so it routes to the first-time prompt or iOS Settings.
    func handleTrackingTap() async {
        await tracking.promptOrOpenSettings()
        isTrackingAuthorized = tracking.isAuthorized
    }

    /// Establishes/validates the Graph setup with the current Facebook token and
    /// classifies the outcome. On a recoverable auth failure the stale session is
    /// cleared so the next login starts clean.
    func validateSetup(markLoginAttempt: Bool = false) async {
        if markLoginAttempt { settings.pressedFBLoginButton = true }
        isValidating = true
        defer { isValidating = false }

        let token = facebookSessionService.currentToken()
        AppLogger.login.info("Setup token check: \(token.diagnostic, privacy: .public)")
        guard let tokenString = token.tokenString else {
            resetFacebookSession()
            result = .sessionExpired
            return
        }
        do {
            try await gateway.setup(facebookToken: tokenString)
            connectedViaLogin = markLoginAttempt
            result = .connected
        } catch {
            AppLogger.login.info("Setup failed: \(error.localizedDescription, privacy: .public)")
            if Self.isRecoverableAuthFailure(error) {
                resetFacebookSession()
                result = .sessionExpired
            } else {
                result = .failed(message: error.localizedDescription)
            }
        }
    }

    func resetFacebookSession() {
        facebookSessionService.resetSession()
        gateway.reset()
        settings.pressedFBLoginButton = false
        AppLogger.login.info("Facebook SDK session and connected insights setup were reset.")
    }

    /// Clears a consumed result so the view won't re-trigger its alert/dismiss.
    func clearResult() {
        result = nil
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
