import Foundation
import FBSDKLoginKit

protocol FacebookSessionServiceProtocol {
    func currentToken() -> FBToken
    func resetSession()
}

final class FacebookSessionService: FacebookSessionServiceProtocol {
    func currentToken() -> FBToken {
        FBToken()
    }

    func resetSession() {
        LoginManager().logOut()
    }
}
