//
//  GetJsonSUI+Filling.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension AnalyticsVCModels {
    static var lastSelected = 0
    
    func fillData(){
        
        //Security check:
        //Only fill data if there is data else return
        if processedJson?.rates == Optional([]) { return }
        
        //
        self.overviewSectionData[0].currentData = processedJson?.avg0 ?? "0" //avg likes
        self.overviewSectionData[1].currentData = processedJson?.avg1 ?? "0" //avg com
        
        //
        self.circles_Data[1].currentData = processedJson?.rates[AnalyticsVCModels.lastSelected] ?? 0 //Selection default value
        self.circles_Data[1].goal = getMaxRate()
        
        //
        let avEng: CGFloat = processedJson?.avg2 ?? 0 //avg engagement
        self.circles_Data[0].currentData = avEng
        self.circles_Data[0].goal = avEng
    }
    
    func fillGraphData () {
        guard let rates = processedJson?.rates else {return}
        let maxR = getMaxRate()
        
        if barChartData != nil {
            barChartData?.removeAll()
        }
        
        if (rates.count) > 0 {
            //Graph data
            for i in 0 ... (rates.count)-1 {
                barChartData?.append(
                    Post(
                        id: i,
                        post: "\(i+1)",
                        r: CGFloat(rates[i]!),
                        barHeight:  ((rates[i]!) / maxR) * 50 + 5, //80
                        rVr: 0))
            }
        }
    }
    
    func getMaxRate () -> CGFloat {
        let maxR = processedJson?.maxR == nil || processedJson?.maxR == 0 ? 1 : processedJson?.maxR
        return maxR!
    }
}
