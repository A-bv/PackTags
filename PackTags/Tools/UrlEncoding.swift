//
//  GJs+.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

extension String {
    func encodeUrl () -> String? {
        //URLs must be encoded: "," = "%2C", "{" = "%7B", "}" = "%7D"
        
        guard let encodedUrl = self.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        else { return nil }
        return encodedUrl.replacingOccurrences(of: ",", with: "%2C")
    }
}
