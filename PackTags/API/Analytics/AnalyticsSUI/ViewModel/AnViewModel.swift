//
//  SwiftUIData.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI
import Combine

class ANewVCDataSUI: ObservableObject {
    
    private enum Strings {
        static let likes = "Likes".localized()
        static let comments = "Comments".localized()
        static let average = "Average".localized()
        static let selection = "Selection".localized()
    }
    
    //MARK: - Live Variables
    @Published var processedJson : processedProfileModel?
    @Published var jsonOfficial : Profile? //Api Graph
    @Published var stats_Data = [
        Stats(
            id: 0,
            title: Strings.likes,
            currentData: "0",
            goal: 0,
            color: Color("running"),
            image: Image(systemName: "suit.heart.fill")),
        Stats(
            id: 1,
            title: Strings.comments,
            currentData: "0",
            goal: 0,
            color: Color("water"),
            image: Image(systemName: "text.bubble.fill"))]
    
    @Published var circles_Data = [
        Circles(
            id: 0,
            title: Strings.average,
            currentData: 0,
            goal: 0,
            color: Color("running"),
            variation: 0),
        Circles(
            id: 1,
            title: Strings.selection,
            currentData: 0,
            goal: 0,
            color: Color("water"),
            variation: 0)
    ]
    @Published var graph_Data: [Post]? = [Post(id: 0, post: "", r: 0, barHeight: 0, rVr: 0)]
    
    //VARR
    //@Published var engagementVariations : engagementVariations?
    
    //MARK: - Init
    //Load data for AnalyticsNew (AnalyticsNew's func list)
    
    init() {
        GetJson.canRefresh() == true ? self.getOnlineJsonAPIGraph() : self.getJsonFromDir()
    }
    //init() { runGetTests ()}
    //init() {self.getJsonFromDir()}
}
