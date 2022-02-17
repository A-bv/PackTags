//
//  SwiftUIData.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

//For swift UI

import FBSDKLoginKit
import SwiftUI

#if canImport(Combine)
import Combine
#if (arch(x86_64) || arch(arm64))

@available(iOS 13.0, *)
class ANewVCDataSUI: ObservableObject {
    
    //MARK: - Live Variables
    @Published var processedJson : processedProfileModel?
    @Published var jsonOfficial : Profile? //Api Graph
    @Published var stats_Data = [
        Stats(id: 0, title: "Likes", currentData: "0", goal: 0, color: Color("running"), image: Image(systemName: "suit.heart.fill")),
        Stats(id: 1, title: "Comments", currentData: "0", goal: 0, color: Color("water"), image: Image(systemName: "text.bubble.fill"))]
    @Published var circles_Data = [
        Circles(id: 0, title: "Average", currentData: 0, goal: 0, color: Color("running"), variation: 0),
        Circles(id: 1, title: "Selection", currentData: 0, goal: 0, color: Color("water"), variation: 0)
    ]
    @Published var graph_Data: [Post]? = [Post(id: 0, post: "", r: 0, barHeight: 0, rVr: 0)]
    @Published var engagementVariations : engagementVariations? //VARR
    
    //MARK: - Init
    //Load data for AnalyticsNew (AnalyticsNew's func list)
    
    init() {
        GetJson.canRefresh() == true ? self.getOnlineJsonAPIGraph() : self.getJsonFromDir()
    }
    //init() { runGetTests ()}
    //init() {self.getJsonFromDir()}
}

#endif
#endif

