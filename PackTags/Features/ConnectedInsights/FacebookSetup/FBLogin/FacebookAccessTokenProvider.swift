//
//  FacebookAccessTokenProvider.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.06.26.
//  Copyright © 2026 Alexandre Bevilacqua. All rights reserved.
//

import FBSDKLoginKit
import InstagramGraph

struct FacebookAccessTokenProvider: InstagramGraphAccessTokenProviding {
    var facebookToken: String? {
        guard let token = AccessToken.current, !token.isExpired else {
            return nil
        }
        return token.tokenString
    }
}
