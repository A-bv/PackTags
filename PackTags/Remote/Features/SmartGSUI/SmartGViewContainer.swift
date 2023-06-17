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
    var body: some View {
        SmartGView()
            .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
    }
}
