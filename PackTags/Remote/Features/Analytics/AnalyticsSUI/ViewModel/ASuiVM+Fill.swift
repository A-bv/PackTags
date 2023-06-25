//
//  GetJsonSUI+Filling.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

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
