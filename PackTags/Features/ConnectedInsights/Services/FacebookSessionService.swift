import Foundation
import FBSDKLoginKit

final class FacebookSessionService: FacebookSessionServiceProtocol {
    func currentToken() -> FacebookToken {
        FacebookToken()
    }

    func resetSession() {
        LoginManager().logOut()
    }
}
