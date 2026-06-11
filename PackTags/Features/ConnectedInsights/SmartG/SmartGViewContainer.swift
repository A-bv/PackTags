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
    private let gateway: any ConnectedInsightsGatewayProtocol

    init(gateway: any ConnectedInsightsGatewayProtocol = UnavailableConnectedInsightsGateway()) {
        self.gateway = gateway
    }

    var body: some View {
        SmartGView(gateway: gateway)
            .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
    }
}
