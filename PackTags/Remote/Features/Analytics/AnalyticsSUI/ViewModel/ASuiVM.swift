//
//  SwiftUIData.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 11/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI
import Combine

class AnalyticsSUIViewModel: ObservableObject {
    private enum Strings {
        static let likes = "Likes".localized()
        static let comments = "Comments".localized()
        static let average = "Average".localized()
        static let selection = "Selection".localized()
    }
    
    //MARK: - Live Variables
    @Published var processedJson : TransformedProfileModel?
    @Published var jsonOfficial : Profile? //Api Graph
    @Published var overviewSectionData = [
        AnalyticsOverviewModel(
            id: 0,
            title: Strings.likes,
            value: "0",
            maxValue: 0,
            color: .blue,
            image: Image(systemName: "suit.heart.fill")),
        AnalyticsOverviewModel(
            id: 1,
            title: Strings.comments,
            value: "0",
            maxValue: 0,
            color: .blue,
            image: Image(systemName: "text.bubble.fill"))]
    
    @Published var circlesData = [
        Circles(
            id: 0,
            title: Strings.average,
            value: 0,
            maxValue: 0,
            color: .blue),
        Circles(
            id: 1,
            title: Strings.selection,
            value: 0,
            maxValue: 0,
            color: .blue)
    ]

    @Published var barChartData: [Post] = [Post(id: 0, post: "", rate: 0, barHeight: 0)]
    
    //MARK: - Init
    //Load data for AnalyticsNew (AnalyticsNew's func list)
    
    init() {
        self.canRefresh() == true ? self.getOnlineJsonAPIGraph() : self.getJsonFromDir()
    }
}
