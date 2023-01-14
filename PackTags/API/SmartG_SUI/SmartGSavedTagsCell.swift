//
//  ItemRow.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let sevenDays: TimeInterval = 7 * 24 * 60 * 60
}

struct SmartGSavedTagsCell: View {
    let title: String
    let date: Date
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
            }
            HStack {
                Spacer()
                Text(DateInterval(start: date, duration: Constants.sevenDays))
            }
        }
    }
}

struct SmartGSavedTagsCell_Previews: PreviewProvider {
    static var previews: some View {
        SmartGSavedTagsCell(title: "#Exemple", date: Date())
    }
}
