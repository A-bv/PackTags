//
//  CGLayer+Performance.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.08.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension CALayer {
    func shadowPerformanceBoost() {
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
    }
}
