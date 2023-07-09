//
//  ItemRow.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct SmartGSavedTagsCell: View {
    let title: String
    let date: String
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text(date)
            }
        }
    }
}
