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
    var colors: [Color]
    @ObservedObject var swiftUIData: AnalyticsSUIViewModel
    
    private enum Constants {
        static let opacity: CGFloat = 0.6
        static let barsOpacity: CGFloat = 0.06
        static let barChartHorizontalSpacing: CGFloat = 10
        static let barMaxHeight: CGFloat = 50
        static let barChartTopPadding: CGFloat = 10
    }
    
    var body: some View {
        HStack(spacing: Constants.barChartHorizontalSpacing){
            ForEach(swiftUIData.barChartData ?? []) { value in
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
                            swiftUIData.circles_Data[1].currentData = value.r
                            swiftUIData.circles_Data[1].variation = value.rVr
                            AnalyticsSUIViewModel.lastSelected = value.id
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
        BarchartView(selected: .constant(0), colors: [Color.blue, Color.green], swiftUIData: AnalyticsSUIViewModel())
            .padding()
    }
}
