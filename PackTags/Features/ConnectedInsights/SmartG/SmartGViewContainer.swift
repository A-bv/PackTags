//
//  SmartGViewContainer.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI
import InstagramGraph

struct SmartGViewContainer: View {
    @StateObject var dataController = DataController()
    private let hashtagProvider: any HashtagSearchProviding

    init(hashtagProvider: any HashtagSearchProviding = UnavailableHashtagProvider()) {
        self.hashtagProvider = hashtagProvider
    }

    var body: some View {
        SmartGView(hashtagProvider: hashtagProvider)
            .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
    }
}
