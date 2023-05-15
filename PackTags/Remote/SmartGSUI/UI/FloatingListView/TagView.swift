//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct TagView: View {
    let color: Color
    let index: Int
    let item: String
    @Binding var childSizes: [CGSize]
    @Binding var hashtagsL: [String]
    let x: CGFloat
    let y: CGFloat
    let tagPadding: CGFloat
    let tagCornerRadius: CGFloat
    
    var body: some View {
        Button(action: {
            print(item)
        }) {
            Text("\(item)")
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                childSizes[index] = geometry.size
                            }
                    }
                )
                .foregroundColor(.white)
                .font(.headline)
                .padding(tagPadding)
                .background(color)
                .cornerRadius(tagCornerRadius)
        }
        .offset(x: x, y: y)
    }
}
