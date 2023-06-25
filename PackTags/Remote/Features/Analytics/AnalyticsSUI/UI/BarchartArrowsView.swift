//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

// BarchartArrows
struct BarchartArrowsView: View {
    @ObservedObject var swiftUIData: AnalyticsSUIViewModel // Add this line
    
    private enum Constants {
        static let opacity: CGFloat = 0.6
    }
    
    private enum Strings {
        static let previousPosts = "Previous posts".localized()
        static let previousPost = "Previous post".localized()
        static let latest = "Latest post".localized()
    }
    
    var body: some View {
        HStack {
            let num = swiftUIData.processedJson?.postsCount
            if num != 1 {
                Image(systemName: "arrow.turn.left.up")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
                Text(Strings.latest)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
            }
            Spacer()
            
            let leftArrowText = num != 1 ? Strings.previousPosts : Strings.previousPost
            // "Last \(num ?? 0) Posts" : Strings.previousPosts
            Text(leftArrowText)
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
        }
    }
}
