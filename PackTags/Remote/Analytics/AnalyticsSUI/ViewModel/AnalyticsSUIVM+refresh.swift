//
//  AnalyticsSUIVM+refresh.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

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
