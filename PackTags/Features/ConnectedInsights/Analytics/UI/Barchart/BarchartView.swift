//
//  BarchartView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct BarchartView: View {
    private enum Constants {
        static let barChartHorizontalSpacing: CGFloat = 10
    }
    
    @Binding var selectedBarChartPostId: Int
    @Binding var selectedBarChartPostRateValue: CGFloat
    @Binding var barchartPostList: [BarChartPost]
    var colors: [Color]

    var body: some View {
        HStack(spacing: Constants.barChartHorizontalSpacing) {
            ForEach(barchartPostList) { post in
                BarChartItemView(
                    selectedPostId: $selectedBarChartPostId,
                    selectedPostRate: $selectedBarChartPostRateValue,
                    colors: colors,
                    post: post)
            }
        }
    }
}

struct BarchartView_Previews: PreviewProvider {
    static var previews: some View {
        let data = [
            BarChartPost(id: 1, post: "Post1", rate: CGFloat(0), barHeight: CGFloat(32.5)),
            BarChartPost(id: 2, post: "Post2", rate: CGFloat(0), barHeight: CGFloat(43.75)),
            BarChartPost(id: 3, post: "Post3", rate: CGFloat(0), barHeight: CGFloat(22.5)),
            BarChartPost(id: 1, post: "Post1", rate: CGFloat(0), barHeight: CGFloat(32.5)),
            BarChartPost(id: 2, post: "Post2", rate: CGFloat(0), barHeight: CGFloat(43.75)),
            BarChartPost(id: 3, post: "Post3", rate: CGFloat(0), barHeight: CGFloat(22.5))
        ]
        BarchartView(
            selectedBarChartPostId: .constant(2),
            selectedBarChartPostRateValue: .constant(0.0),
            barchartPostList: .constant(data),
            colors: [.blue, .green])
        .padding()
    }
}
