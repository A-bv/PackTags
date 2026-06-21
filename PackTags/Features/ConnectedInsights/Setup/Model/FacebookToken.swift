import FBSDKLoginKit

struct FacebookToken {
    let tokenString: String?
    let diagnostic: String

    init(tokenString: String?, diagnostic: String = "") {
        self.tokenString = tokenString
        self.diagnostic = diagnostic
    }

    /// Reads the live FBSDK session. Note this is presence only — whether the token is
    /// actually accepted is decided by the Graph API, not by a local expiry check.
    init() {
        guard let token = AccessToken.current else {
            tokenString = nil
            diagnostic = "AccessToken.current=nil"
            return
        }
        tokenString = token.tokenString
        diagnostic = "AccessToken.current=present, isExpired=\(token.isExpired), expirationDate=\(token.expirationDate)"
    }
}
