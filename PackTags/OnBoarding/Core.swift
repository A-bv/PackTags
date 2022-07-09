//
//  Core.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

class Core {
    static let shared = Core()
    
    func isNewUser () -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser () {
        UserDefaults.standard.setValue(true, forKey: "isNewUser")
    }
}
