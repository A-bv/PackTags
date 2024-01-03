//
//  BarchartItemView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 03.01.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct BarChartItemView: View {
    private enum Constants {
        static let opacity: CGFloat = 0.6
        static let barsOpacity: CGFloat = 0.06
        static let barMaxHeight: CGFloat = 50
        static let barChartTopPadding: CGFloat = 10
    }
    
    var value: BarChartPost
    @Binding var selected: Int
    @Binding var rate: CGFloat
    var colors: [Color]

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            RoundedShape()
                .fill(
                    LinearGradient(
                        gradient: .init(
                            colors: selected == value.id
                                ? colors
                                : [Color(UIColor.label).opacity(Constants.barsOpacity)]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: value.barHeight)
                .onTapGesture {
                    withAnimation(.easeOut) {
                        selected = value.id
                        rate = value.rate
                        let impactMed = UIImpactFeedbackGenerator(style: .soft)
                        impactMed.impactOccurred()
                    }
                }

            Text(value.post)
                .font(.caption2)
                .foregroundColor(Color(UIColor.label))
        }
        .frame(
            height: Constants.barMaxHeight + Constants.barChartTopPadding
        )
    }
}
