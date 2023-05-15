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
    
    init() {
        if let token = AccessToken.current, !token.isExpired {
            tokenString = token.tokenString
            isValid = true
        } else {
            tokenString = nil
            isValid = false
        }
    }
}
