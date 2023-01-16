//
//  SmartGStoryCard.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Strings {
    static let loading3Dots = "Loading...".localized()
}

private enum Constants {
    static let cardLabelFontSize: CGFloat = 12
    static let cardCornerRadius: CGFloat = 12
    static let cardWidth: CGFloat = 160
    static let cardHeigth: CGFloat = 190
}

struct StoryCard: View{
    let url: URL
    let comments: String
    let likes: String
    let hashtagsCount: String
    
    var body: some View{
        VStack(alignment: .leading){
            //URLImage(urlString: url)
            AsyncImage(
                url: url,
                placeholder: {
                    Text(Strings.loading3Dots)
                },
                image: { Image(uiImage: $0).resizable() })
            .aspectRatio(contentMode: .fill)
            .frame(
                width: Constants.cardWidth,
                height: Constants.cardHeigth)
            .clipShape(
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
            
            HStack(){
                if comments != "0" {
                    Image(systemName: "text.bubble.fill")
                    Text(comments)
                        .font(.system(size: Constants.cardLabelFontSize, weight: .semibold))
                }
                if likes != "0" {
                    Image(systemName: "suit.heart.fill")
                    Text(likes)
                        .font(.system(size: Constants.cardLabelFontSize, weight: .semibold))
                }
                if hashtagsCount != "0" {
                    Image(systemName: "number.circle.fill")
                    Text(hashtagsCount)
                        .font(.system(size: Constants.cardLabelFontSize, weight: .semibold))
                }
                Spacer()
            }
        }
    }
}
