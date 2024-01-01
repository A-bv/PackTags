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
    init() {
        self.loadDataForAnalyticsNew()
    }
    
    private func loadDataForAnalyticsNew() {
        canRefresh() == true ? getOnlineJsonAPIGraph() : getJsonFromDir()
    }
}

extension AnalyticsSUIViewModel {
    func fillData(){
        //Security check:
        //Only fill data if there is data else return
        if processedJson?.rates == Optional([]) { return }
        
        //
        self.overviewSectionData[0].value = processedJson?.avg0 ?? "0" //avg likes
        self.overviewSectionData[1].value = processedJson?.avg1 ?? "0" //avg com
        
        //
        self.circlesData[1].value = processedJson?.rates[0] ?? 0
        self.circlesData[1].maxValue = getMaxRate()
        
        //
        let avEng: CGFloat = processedJson?.avg2 ?? 0 //avg engagement
        self.circlesData[0].value = avEng
        self.circlesData[0].maxValue = avEng
    }
    
    func fillGraphData () {
        guard let rates = processedJson?.rates else { return }
        let maxR = getMaxRate()
        
        barChartData.removeAll()
        
        if (rates.count) > 0 {
            //Graph data
            for i in 0 ... (rates.count)-1 {
                barChartData.append(
                    Post(
                        id: i,
                        post: "\(i+1)",
                        rate: CGFloat(rates[i]!),
                        barHeight:  ((rates[i]!) / maxR) * 50 + 5)) //80
            }
        }
    }
    
    private func getMaxRate() -> CGFloat {
        let max = processedJson?.maxR
        return (max == nil || max == 0 ? 1 : max)!
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
