//
//  Alert.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

class Utility: NSObject {
    
    deinit {
        print("deinit utility")
    }
    
    class func isDarkMode () -> Bool {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return true
            }
            else {
                return false
            }
        } else {
            return false
        }
    }
}


