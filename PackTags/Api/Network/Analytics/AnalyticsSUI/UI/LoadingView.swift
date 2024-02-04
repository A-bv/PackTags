//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 29.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @Binding var loading: Bool
    private enum Constants {
        static let loadingIndicatorFrame: CGFloat = 70
        static let indicatorColor: Color = Color("customPurple")
    }

    var body: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)

            ActivityIndicatorView(isVisible: $loading, type: .rotatingDots)
                .foregroundColor(Constants.indicatorColor)
                .frame(
                    width: Constants.loadingIndicatorFrame,
                    height: Constants.loadingIndicatorFrame,
                    alignment: .center)
        }
    }
}
