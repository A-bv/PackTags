import SwiftUI
import FBSDKLoginKit

/// SwiftUI wrapper around the UIKit `FBLoginButton`. Classic login (`.enabled`) is
/// mandatory — Limited Login only yields an OIDC token the Instagram Graph calls
/// can't use. `onComplete` fires on success or error (not on cancel); the caller
/// validates the resulting token against the Graph.
struct FacebookLoginButton: UIViewRepresentable {
    let permissions: [String]
    /// Fires the instant the button starts its login flow (before the consent sheet) —
    /// the only chance to show feedback while the SDK spins up.
    let onWillLogin: () -> Void
    let onComplete: (Error?) -> Void
    let onCancel: () -> Void
    let onLogOut: () -> Void

    func makeUIView(context: Context) -> FBLoginButton {
        let button = FBLoginButton()
        button.loginTracking = .enabled
        button.permissions = permissions
        button.delegate = context.coordinator
        return button
    }

    func updateUIView(_ uiView: FBLoginButton, context: Context) {
        uiView.permissions = permissions
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onWillLogin: onWillLogin, onComplete: onComplete, onCancel: onCancel, onLogOut: onLogOut)
    }

    final class Coordinator: NSObject, @preconcurrency LoginButtonDelegate {
        private let onWillLogin: () -> Void
        private let onComplete: (Error?) -> Void
        private let onCancel: () -> Void
        private let onLogOut: () -> Void

        init(
            onWillLogin: @escaping () -> Void,
            onComplete: @escaping (Error?) -> Void,
            onCancel: @escaping () -> Void,
            onLogOut: @escaping () -> Void
        ) {
            self.onWillLogin = onWillLogin
            self.onComplete = onComplete
            self.onCancel = onCancel
            self.onLogOut = onLogOut
        }

        @MainActor
        func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
            onWillLogin()
            return true
        }

        @MainActor
        func loginButton(
            _ loginButton: FBLoginButton,
            didCompleteWith result: LoginManagerLoginResult?,
            error: Error?
        ) {
            guard result?.isCancelled != true else { return onCancel() }
            onComplete(error)
        }

        @MainActor
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            onLogOut()
        }
    }
}
