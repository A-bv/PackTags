//
//  AnOverviewSectionModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct AnalyticsOverviewModel : Identifiable {
    var id: Int
    var title: String
    var value: String
    var maxValue: CGFloat
    var color: Color
    var image: Image
}
