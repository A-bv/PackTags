//
//  StoryCardLabel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let cardLabelFontSize: CGFloat = 12
}

enum StoryCardLabelType {
    case comments
    case likes
    case hashtags
}

struct StoryCardLabel: View {
    let comments: String
    let likes: String
    let hashtagsCount: String
    
    var body: some View {
        HStack {
            switchType(type: .comments, count: comments)
            switchType(type: .likes, count: likes)
            switchType(type: .hashtags, count: hashtagsCount)
        }
        .foregroundColor(.white)
        .background(Color.pink)
    }
    
    @ViewBuilder
    private func switchType(type: StoryCardLabelType, count: String) -> some View {
        if count != "0" {
            switch type {
            case .comments:
                Image(systemName: "text.bubble.fill")
            case .likes:
                Image(systemName: "suit.heart.fill")
            case .hashtags:
                Image(systemName: "number.circle.fill")
            }
            Text(count)
                .font(.system(size: Constants.cardLabelFontSize, weight: .semibold))
        }
    }
}
