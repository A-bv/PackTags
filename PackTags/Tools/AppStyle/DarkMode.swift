//
//  Alert.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

class DarkMode: NSObject {
    class func isDarkMode () -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}


