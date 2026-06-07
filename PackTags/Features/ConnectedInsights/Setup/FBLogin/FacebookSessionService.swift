import Foundation
import FBSDKLoginKit

protocol FacebookSessionServicing {
    func currentToken() -> FBToken
    func resetSession()
}

final class FacebookSessionService: FacebookSessionServicing {
    func currentToken() -> FBToken {
        FBToken()
    }

    func resetSession() {
        LoginManager().logOut()
    }
}
