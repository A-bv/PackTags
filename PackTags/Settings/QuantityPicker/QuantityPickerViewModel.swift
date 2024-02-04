//
//  QuantityPickerViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

class QuantityPickerViewModel {
    private enum Constants {
        static let minCount = 5
        static let maxCount = 30
    }
    
    var selectedValue: Int {
        get {
            let savedTagQuantity = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")
            return savedTagQuantity == 0 ? Constants.maxCount : savedTagQuantity
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "QuantityOfTagsPerPack")
        }
    }
    
    var pickerValuesArray: [Int] {
        return Array(Constants.minCount...Constants.maxCount).reversed()
    }
}
