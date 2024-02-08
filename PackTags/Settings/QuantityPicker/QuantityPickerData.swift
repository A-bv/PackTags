//
//  QuantityPickerViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

enum QuantityPickerData {
    private enum Constants {
        static let minCount = 5
        static let maxCount = 30
        static let key = "QuantityOfTagsPerPack"
    }
    
    static var selectedValue: Int {
        get {
            let savedValue = UserDefaults.standard.integer(forKey: Constants.key)
            return savedValue == 0 ? Constants.maxCount : savedValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.key)
        }
    }
    
    static var pickerValuesArray: [Int] {
        return Array(Constants.minCount...Constants.maxCount).reversed()
    }
}
