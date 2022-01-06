//
//  GJs+CanRf.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 03/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

//MARK: - is allowed to refresh
extension GetJson {
    class func canRefresh () -> Bool {
        
        if UserDefaults.standard.object(forKey: "LastStatsRefresh") == nil {
            return true
        } else {
            let date0 = UserDefaults.standard.object(forKey: "LastStatsRefresh") as! Date
            
            /*
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy HH:mm"
            print("Last refresh at",df.string(from: date0))
            */
            
            //Allow a fetch each day
            let timeInterval = 5 //7200//2hours 86400//day  // Seconds
            if date0 + TimeInterval(timeInterval) > Date() {
                return false
            } else {
                UserDefaults.standard.set(Date(), forKey: "LastStatsRefresh")
                print("Time updated")
                return true
            }
        }
    }
}
