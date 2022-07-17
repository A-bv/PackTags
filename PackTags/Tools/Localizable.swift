//
//  Localizable.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle:.main,
            value: self,
            comment: self
        )
    }
}
