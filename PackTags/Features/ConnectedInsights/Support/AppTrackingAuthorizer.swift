import AppTrackingTransparency
import UIKit

@MainActor
protocol AppTrackingAuthorizerProtocol {
    var isAuthorized: Bool { get }
    func requestIfNeeded() async -> Bool
    func promptOrOpenSettings() async
}

/// Facebook's classic AccessToken is only accepted by the Graph API once tracking is
/// authorized (FBSDK 17+). iOS won't let the app flip ATT itself, so we can only
/// present the one-shot prompt or route the user to the app's Settings page.
struct AppTrackingAuthorizer: AppTrackingAuthorizerProtocol {
    var isAuthorized: Bool {
        ATTrackingManager.trackingAuthorizationStatus == .authorized
    }

    /// Presents the ATT prompt if the user hasn't answered yet, then reports whether
    /// tracking ended up authorized.
    func requestIfNeeded() async -> Bool {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { _ in continuation.resume() }
            }
        }
        return isAuthorized
    }

    /// Fires the one-shot prompt if never asked; otherwise opens the app's iOS Settings
    /// page — the only place to change tracking afterwards.
    func promptOrOpenSettings() async {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            _ = await requestIfNeeded()
        } else {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            await UIApplication.shared.open(url)
        }
    }
}
