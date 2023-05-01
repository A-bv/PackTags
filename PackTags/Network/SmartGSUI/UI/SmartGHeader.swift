//
//  SmartGHeader.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Strings {
    static let smartHashtags = "Smart Hashtags".localized()
    static let hashtagsPageSearch = "Hashtag page search".localized()
}

private enum Constants {
    static let headerHorizontalEdgePadding: CGFloat = 20
    static let headerInterTitlesPadding: CGFloat = 5
    static let headerBottomPadding: CGFloat = 15
}

struct SmartGHeader: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.headerInterTitlesPadding) {
                Text(Strings.smartHashtags)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
                
                Text(Strings.hashtagsPageSearch)
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))
                
            }
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.down.circle")
                    .font(Font.system(.title))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding(.horizontal, Constants.headerHorizontalEdgePadding)
        .padding(.bottom, Constants.headerBottomPadding)
    }
}
