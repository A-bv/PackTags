//
//  FormatJson.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.01.21.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
   
class StringFormatter: NSObject {
    class func averageElementsOfArray (a: [Int]) -> String {
        let avgNS = (a as NSArray).value(forKeyPath: "@avg.floatValue") as? NSNumber
        let avgDbl = avgNS?.doubleValue
        return formatNum(value: avgDbl ?? 0) //String(format: "%.2f", avgDbl ?? 0)
    }
    
    class func formatNum (value : Double, noDecimal: Bool = false) -> String {
        var text = String()
        switch value {
        case  ..<0.01:
            text = String(format: "%.0f",value)
        case 0.01 ..< 100:
            text = !noDecimal ? String(format: "%.1f",value) : String(format: "%.0f",value)
        case 100  ..< 1_000:
            text = String(format: "%.0f",value)
        case 1_000 ..< 999_999:
            text = String(format: "%.1fK", value/1000).replacingOccurrences(of: ".0", with: "")
        default:
            text = String(format: "%.1fM", value/1_000_000).replacingOccurrences(of: ".0", with: "")
        }
        return text
    }
    
    /*
    //VARR
    func extraFormatNum (value : Double) -> String {
        var output = String()
        if value < 0 {
            output = "▼ " + formatNum(value: -value) + "%"
        } else {
            output = "▲ " + formatNum(value: value) + "%"
        }
        if value == 0 { output = "" }
        if value.isInfinite == true { output = "" }
        return output
    }*/
}
