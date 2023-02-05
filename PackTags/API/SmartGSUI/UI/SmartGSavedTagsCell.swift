//
//  ItemRow.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let sevenDaysSeconds: TimeInterval = 7 * 24 * 60 * 60
    static let sevenDays: Int = 7
}

private enum Strings {
    static let left = "left"
    static let days = "days"
}

struct SmartGSavedTagsCell: View {
    let title: String
    let date: Date
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                if let timeLeft = timeLeft() {
                    Text(timeLeft)
                }
            }
        }
    }

    func timeLeft() -> String? {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = Constants.sevenDays
        guard
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: date),
            let days = Calendar.current.dateComponents(
                [.day, .minute, .second],
                from: currentDate,
                to: futureDate).day
        else { return nil }
        return String(days) + " " + Strings.days + " " + Strings.left
    }
}

struct SmartGSavedTagsCell_Previews: PreviewProvider {
    static var previews: some View {
        SmartGSavedTagsCell(title: "#Exemple", date: Date())
    }
}

