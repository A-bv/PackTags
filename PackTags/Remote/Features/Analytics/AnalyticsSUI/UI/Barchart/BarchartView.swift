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
    
    @Binding var selected: Int
    @Binding var rate: CGFloat
    @Binding var chartData: [BarChartPost]
    var colors: [Color]

    var body: some View {
        HStack(spacing: Constants.barChartHorizontalSpacing) {
            ForEach(chartData) { value in
                BarChartItemView(
                    value: value,
                    selected: $selected,
                    rate: $rate,
                    colors: colors
                )
            }
        }
    }
}

struct BarchartView_Previews: PreviewProvider {
    static var previews: some View {
        let data = [
            BarChartPost(id: 1, post: "Post1", rate: CGFloat(0), barHeight: CGFloat(32.5)),
            BarChartPost(id: 2, post: "Post2", rate: CGFloat(0), barHeight: CGFloat(43.75)),
            BarChartPost(id: 3, post: "Post3", rate: CGFloat(0), barHeight: CGFloat(22.5))
        ]
        BarchartView(
            selected: .constant(2),
            rate: .constant(0.0),
            chartData: .constant(data),
            colors: [.blue, .green])
        .padding()
    }
}
