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

    let profileProvider: any ProfileDataProviding

    @Published var mode: Int = 0
    @Published var rawInsights: Bool = true

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

    @Published var barChartData: [BarChartPost] = [BarChartPost(id: 0, post: "", rate: 0, barHeight: 0)]
    
    //MARK: - Init
    init(profileProvider: any ProfileDataProviding = UnavailableProfileProvider()) {
        self.profileProvider = profileProvider
        self.loadDataForAnalyticsNew()
    }
    
    private func loadDataForAnalyticsNew() {
        canRefresh() == true ? getOnlineJsonAPIGraph() : getJsonFromDir()
    }
}

extension AnalyticsSUIViewModel {
    private enum Constants {
        static let timeForRefresh = 5
    }
    
    func canRefresh () -> Bool {
        let defaults = UserDefaults.standard
        guard let lastRefreshTime = defaults.object(forKey: "LastStatsRefresh") else { return true }
        
        let date0 = lastRefreshTime as! Date
        
        /*
         let df = DateFormatter()
         df.dateFormat = "dd/MM/yyyy HH:mm"
         print("Last refresh at",df.string(from: date0))
         */
        
        //Allow a fetch each day
        let timeInterval = Constants.timeForRefresh//7200//2hours 86400//day  // Seconds
        if date0 + TimeInterval(timeInterval) > Date() {
            return false
        } else {
            defaults.set(Date(), forKey: "LastStatsRefresh")
            print("Time updated")
            return true
        }
    }
}
