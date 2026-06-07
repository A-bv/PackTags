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
    private let smartGDataProvider: any SmartGDataProviding

    init(smartGDataProvider: any SmartGDataProviding = UnavailableSmartGDataProvider()) {
        self.smartGDataProvider = smartGDataProvider
    }

    var body: some View {
        SmartGView(smartGDataProvider: smartGDataProvider)
            .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
    }
}
