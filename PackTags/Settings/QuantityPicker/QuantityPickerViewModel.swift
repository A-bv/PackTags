//
//  QuantityPickerViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

class QuantityPickerViewModel {
    private let minimumTagNumber = 5
    private let maximumTagNumber = 30
    
    var numTagsInPack: Int {
        get {
            let savedTagQuantity = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")
            return savedTagQuantity == 0 ? maximumTagNumber : savedTagQuantity
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "QuantityOfTagsPerPack")
        }
    }
    
    var dataArray: [Int] {
        return Array(minimumTagNumber...maximumTagNumber).reversed()
    }
}
