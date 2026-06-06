//
//  RoundShape.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct RoundedShape : Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft,.topRight],
            cornerRadii: CGSize(width: 5, height: 5))
        return Path(path.cgPath)
    }
}
