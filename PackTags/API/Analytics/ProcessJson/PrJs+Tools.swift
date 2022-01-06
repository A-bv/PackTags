//
//  FormatJson.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.01.21.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//


import UIKit

extension ProcessJson {
    class func averageElementsOfArray (a: [Int]) -> String {
        let avgNS = (a as NSArray).value(forKeyPath: "@avg.floatValue") as? NSNumber
        let avgDbl = avgNS?.doubleValue
        let avg = formatNum(value: avgDbl ?? 0)
            //String(format: "%.2f", avgDbl ?? 0)
        return avg
    }
    
    class func averageElementOfArrayCGFloat (a: [CGFloat]) -> CGFloat {
        return a.reduce(0.0) { return $0 + $1/CGFloat(a.count)}
    }
    
    class func formatNum (value : Double) -> String {
        var text = String()
        switch value {
        case  ..<0.01:
            text = String(format: "%.0f",value)
        case 0.01 ..< 100:
            text = String(format: "%.1f",value)
        case 100  ..< 1_000:
            text = String(format: "%.0f",value)
        case 1_000 ..< 999_999:
            text = String(format: "%.1fK", value/1000).replacingOccurrences(of: ".0", with: "")
        default:
            text = String(format: "%.1fM", value/1_000_000).replacingOccurrences(of: ".0", with: "")
        }
        return text
    }
    
    //VARR
    class func extraFormatNum (value : Double) -> String {
        var output = String()
        if value < 0 {
            output = "▼ " + formatNum(value: -value) + "%"
        } else {
            output = "▲ " + formatNum(value: value) + "%"
        }
        if value == 0 { output = "" }
        if value.isInfinite == true { output = "" }
        return output
    }
}
