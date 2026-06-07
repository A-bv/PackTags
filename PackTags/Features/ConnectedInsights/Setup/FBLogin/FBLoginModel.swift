//
//  FBLoginModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import FBSDKLoginKit

struct FBToken {
    let tokenString: String?
    let isValid: Bool
    let diagnostic: String
    
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
