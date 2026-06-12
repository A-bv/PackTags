import FBSDKLoginKit

struct FBToken {
    let tokenString: String?
    let isValid: Bool
    let diagnostic: String

    init(tokenString: String?, isValid: Bool = false, diagnostic: String = "") {
        self.tokenString = tokenString
        self.isValid = isValid
        self.diagnostic = diagnostic
    }

    /// Reads the live FBSDK session.
    init() {
        guard let token = AccessToken.current else {
            tokenString = nil
            isValid = false
            diagnostic = "AccessToken.current=nil"
            return
        }

        tokenString = token.tokenString
        isValid = !token.isExpired
        diagnostic = "AccessToken.current=present, isExpired=\(token.isExpired), expirationDate=\(token.expirationDate)"
    }
}
