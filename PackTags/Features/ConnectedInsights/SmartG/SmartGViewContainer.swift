//
//  SmartGViewContainer.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.01.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct SmartGViewContainer: View {
    @StateObject var dataController = DataController()
    private let instagramGraphService: any InstagramGraphServicing

    init(instagramGraphService: any InstagramGraphServicing = InstagramGraphService()) {
        self.instagramGraphService = instagramGraphService
    }

    var body: some View {
        SmartGView(instagramGraphService: instagramGraphService)
            .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
    }
}
