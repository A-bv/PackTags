//
//  GetJsonSUI+Tools.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

//Circles
struct Circles : Identifiable {
    var id: Int
    var title: String
    var value: CGFloat
    var maxValue: CGFloat
    var color: Color
}

// graph Data...
struct Post: Identifiable {
    var id: Int
    var post: String
    var rate: CGFloat
    var barHeight: CGFloat
}
