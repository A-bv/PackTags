import Foundation
import FBSDKLoginKit

protocol FacebookSessionServiceProtocol {
    func currentToken() -> FacebookToken
    func resetSession()
}

final class FacebookSessionService: FacebookSessionServiceProtocol {
    func currentToken() -> FacebookToken {
        FacebookToken()
    }

    func resetSession() {
        LoginManager().logOut()
    }
}
