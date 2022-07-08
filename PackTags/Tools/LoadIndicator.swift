//
//  ActivityIndicator.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI
import Combine

@available(iOS 13, *)
public struct ActivityIndicatorView: View {

    public enum IndicatorType {
        case rotatingDots
    }

    @Binding var isVisible: Bool
    var type: IndicatorType

    public init(isVisible: Binding<Bool>, type: IndicatorType) {
        self._isVisible = isVisible
        self.type = type
    }

    public var body: some View {
        guard isVisible else { return AnyView(EmptyView()) }
        return AnyView(RotatingDotsIndicatorView())
    }
}

@available(iOS 13, *)
struct RotatingDotsIndicatorView: View {

    private let count: Int = 5

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.count, id: \.self) { index in
                RotatingDotsIndicatorItemView(index: index, size: geometry.size)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

@available(iOS 13, *)
struct RotatingDotsIndicatorItemView: View {

    let index: Int
    let size: CGSize

    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        let animation = Animation
            .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
            .repeatForever(autoreverses: false)

        return Circle()
            .frame(width: size.width / 5, height: size.height / 5)
            .scaleEffect(scale)
            .offset(y: size.width / 10 - size.height / 2)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                self.rotation = 0
                self.scale = (5 - CGFloat(self.index)) / 5
                withAnimation(animation) {
                    self.rotation = 360
                    self.scale = (1 + CGFloat(self.index)) / 5
                }
            }
    }
}
