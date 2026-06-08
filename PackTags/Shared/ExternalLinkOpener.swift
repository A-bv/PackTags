//
//  AppUrlHandler.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

final class ExternalLinkOpener {
    static func openAppURL(appURL: String, webURL: String) {
        let application = UIApplication.shared
        
        if let appURL = URL(string: appURL),
           application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            let webURLToOpenWithSafari = URL(string: webURL)!
            application.open(webURLToOpenWithSafari)
        }
    }
}
