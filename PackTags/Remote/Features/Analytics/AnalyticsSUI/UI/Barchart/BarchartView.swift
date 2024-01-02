//
//  BarchartView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

// Barchart
struct BarchartView: View {
    @Binding var selected: Int
    @Binding var rate: CGFloat
    @Binding var chartData: [BarChartPost]
    var colors: [Color]
    
    private enum Constants {
        static let opacity: CGFloat = 0.6
        static let barsOpacity: CGFloat = 0.06
        static let barChartHorizontalSpacing: CGFloat = 10
        static let barMaxHeight: CGFloat = 50
        static let barChartTopPadding: CGFloat = 10
    }
    
    var body: some View {
        HStack(spacing: Constants.barChartHorizontalSpacing){
            ForEach(chartData) { value in
                // Bars...
                VStack{
                    VStack{
                        Spacer(minLength: 0)
                        
                        RoundedShape()
                            .fill(
                                LinearGradient(
                                    gradient: .init(
                                        colors: selected == value.id
                                        ? colors
                                        : [Color(UIColor.label).opacity(Constants.barsOpacity)]),
                                    startPoint: .top, endPoint: .bottom))
                        
                        // max height = 50
                            .frame(height: value.barHeight)
                        
                    }
                    .frame(
                        height: Constants.barMaxHeight + Constants.barChartTopPadding)
                    .onTapGesture {
                        withAnimation(.easeOut){
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
