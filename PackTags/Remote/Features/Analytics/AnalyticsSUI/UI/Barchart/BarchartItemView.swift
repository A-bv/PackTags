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

    @Binding var selected: Int
    @Binding var rate: CGFloat
    var colors: [Color]
    var post: BarChartPost
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            gradient: .init(colors: selected == post.id ? colors : [Color(UIColor.label).opacity(Constants.barsOpacity)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func handleTapGesture() {
        withAnimation(.easeOut) {
            selected = post.id
            rate = post.rate
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    var body: some View {
        VStack {
            Spacer()
            RoundedShape()
                .fill(fillGradient)
                .frame(height: post.barHeight)
                .onTapGesture {
                    handleTapGesture()
                }
            Text(post.post)
                .font(.caption2)
                .foregroundColor(Color(UIColor.label))
        }
        .frame(height: Constants.barMaxHeight + Constants.barChartTopPadding)
    }
}
