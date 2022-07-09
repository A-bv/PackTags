//
//  GetJsonSUI+Tools.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

// stats Data...
struct Stats : Identifiable {
    
    var id : Int
    var title : String
    var currentData : String
    var goal : CGFloat
    var color : Color
    var image: Image
}

//Circles
struct Circles : Identifiable {
    
    var id : Int
    var title : String
    var currentData : CGFloat
    var goal : CGFloat
    var color : Color
    var variation : CGFloat
}
