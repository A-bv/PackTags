//
//  CollectionView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let collectionInterMediasPadding: CGFloat = 20
    static let collectionLeadingPadding: CGFloat = 20
    static let collectionBottomPadding: CGFloat = 20
}

struct CollectionView: View {
    @ObservedObject var viewModel: SmartGViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.collectionInterMediasPadding) {
                makeStoryCards()
            }
        }
        .padding(.leading, Constants.collectionLeadingPadding)
        .padding(.bottom, Constants.collectionBottomPadding)
    }
}

extension SmartGView {
    var collection: some View {
        CollectionView(viewModel: self.viewModel)
    }
}
