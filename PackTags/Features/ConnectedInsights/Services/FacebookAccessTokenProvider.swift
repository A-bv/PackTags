import FBSDKLoginKit
import InstagramGraph

/// Supplies the live, SDK-refreshed Facebook token to the InstagramGraph
/// gateway so Graph requests never run on a stale stored copy.
struct FacebookAccessTokenProvider: InstagramGraphAccessTokenProviding {
    var facebookToken: String? {
        guard let token = AccessToken.current, !token.isExpired else {
            return nil
        }
        return token.tokenString
    }
}
