//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct CirclesView: View {
    @Binding var circles: [Circles]
    var isRate: Bool
    let columns: [GridItem]
    
    private enum Constants {
        static let circleTitleToCirclePadding: CGFloat = 25
        static let circleTitleFontSize: CGFloat = 20
        static let circleLineWidth: CGFloat = 10
        static let circleFrameWidthOut: CGFloat = (UIScreen.main.bounds.width - 150 + 20) / 2
        static let circleFrameHeightOut: CGFloat = (UIScreen.main.bounds.width - 150 + 20) / 2
        static let circleFrameWidthInner: CGFloat = (UIScreen.main.bounds.width - 150) / 2
        static let circleFrameHeightInner: CGFloat = (UIScreen.main.bounds.width - 150) / 2
        static let circleTrimStart: CGFloat = 0
        static let circleTrimEnd: CGFloat = 1
        static let gradientStartColor = Color("Color4")
        static let gradientEndColor = Color("Color1")
        static let valueRotationDegrees: Double = 90
        static let circleStartRotationDegrees: Double = -90
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(circles) { circle in
                VStack(spacing: Constants.circleTitleToCirclePadding) {
                    HStack {
                        Text(circle.title)
                            .font(.system(size: Constants.circleTitleFontSize))
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ZStack {
                        Circle()
                            .trim(from: Constants.circleTrimStart, to: Constants.circleTrimEnd)
                            .stroke(Color.clear, lineWidth: Constants.circleLineWidth)
                            .frame(
                                width: Constants.circleFrameWidthOut,
                                height: Constants.circleFrameHeightOut)
                            .background(
                                Circle()
                                    .outerNeumorphism(Color.statsFillColor)
                                    .rotationEffect(.degrees(Constants.valueRotationDegrees)))
                        
                        Circle()
                            .trim(from: Constants.circleTrimStart, to: (circle.value / circle.maxValue))
                            .stroke(
                                LinearGradient(Constants.gradientStartColor, Constants.gradientEndColor),
                                style: StrokeStyle(lineWidth: Constants.circleLineWidth, lineCap: .round))
                            .frame(
                                width: Constants.circleFrameWidthInner,
                                height: Constants.circleFrameHeightInner)

                        Text(
                            StringFormatter.formatValueToText(
                                with: circle.value,
                                isRate: isRate))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(circle.color)
                            .rotationEffect(.init(degrees: Constants.valueRotationDegrees))
                    }
                    .rotationEffect(.init(degrees: Constants.circleStartRotationDegrees))
                }
            }
        }
    }
}

struct CirclesView_Previews: PreviewProvider {
    @State static var circles: [Circles] = [
        Circles(id: 0, title: "Average", value: 203.1, maxValue: 7, color: .blue),
        Circles(id: 1, title: "Selection", value: 133.3, maxValue: 80, color: .blue)
    ]
    
    static var previews: some View {
        let gridItem = GridItem(.flexible())
        ZStack {
            Color.bgFillColor.ignoresSafeArea()
            VStack() {
                CirclesView(
                    circles: $circles,
                    isRate: true,
                    columns: [gridItem])
            }
            .padding(50)
        }
    }
}
