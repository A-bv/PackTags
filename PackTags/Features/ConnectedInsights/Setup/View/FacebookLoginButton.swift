import SwiftUI
import FBSDKLoginKit

/// SwiftUI wrapper around the UIKit `FBLoginButton`. Classic login (`.enabled`) is
/// mandatory — Limited Login only yields an OIDC token the Instagram Graph calls
/// can't use. `onComplete` fires on success or error (not on cancel); the caller
/// validates the resulting token against the Graph.
struct FacebookLoginButton: UIViewRepresentable {
    let permissions: [String]
    let onComplete: (Error?) -> Void
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
        Coordinator(onComplete: onComplete, onLogOut: onLogOut)
    }

    final class Coordinator: NSObject, @preconcurrency LoginButtonDelegate {
        private let onComplete: (Error?) -> Void
        private let onLogOut: () -> Void

        init(onComplete: @escaping (Error?) -> Void, onLogOut: @escaping () -> Void) {
            self.onComplete = onComplete
            self.onLogOut = onLogOut
        }

        @MainActor
        func loginButton(
            _ loginButton: FBLoginButton,
            didCompleteWith result: LoginManagerLoginResult?,
            error: Error?
        ) {
            guard result?.isCancelled != true else { return }
            onComplete(error)
        }

        @MainActor
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            onLogOut()
        }
    }
}
