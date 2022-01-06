//
//  GetJsonSUI+Filling.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
#if (arch(arm64) || arch(x86_64))
@available(iOS 13.0, *)
extension ANewVCDataSUI {
    static var lastSelected = 0
    
    func fillData(){
        
        //Security check:
        //Only fill data if there is data else return
        if engagementVariations?.ratesVr == Optional([]) || processedJson?.rates == Optional([]) {
            return
        }
        
        //
        self.stats_Data[0].currentData = processedJson?.avg0 ?? "0" //avg likes
        self.stats_Data[1].currentData = processedJson?.avg1 ?? "0" //avg com
        
        //
        self.circles_Data[1].currentData = processedJson?.rates[ANewVCDataSUI.lastSelected] ?? 0 //Selection default value
        self.circles_Data[1].goal = getMaxRate()
        
        //
        let avEng: CGFloat = processedJson?.avg2 ?? 0 //avg engagement
        self.circles_Data[0].currentData = avEng
        self.circles_Data[0].goal = avEng
        
        //VARR
        self.circles_Data[0].variation =  engagementVariations?.avg2Vr ?? 0 //avg engagement rate variation
        self.circles_Data[1].variation = engagementVariations?.ratesVr[0] ?? 0 //Selection default value
        
    }
    
    func fillGraphData () {
        let rates = processedJson?.rates
        let maxR = getMaxRate()
        
        if graph_Data != nil {
            graph_Data?.removeAll()
        }
        
        if (rates!.count) > 0 && rates != nil {
           
            //VARR
            // A 0 variation array will not show
            // Initialize a 0 variation array if variations are not computable
            
            // Security check:
            // if somehow there is a variation array count that is no equal to a rates array count
            // or if rate variation is inexistant
            var ratesVr = engagementVariations?.ratesVr
            if ratesVr == nil || ratesVr?.count != rates?.count {
                // Initialise a new 0 variation array, lenght: rates count
                ratesVr = [CGFloat?](repeating: 0, count: rates!.count)
            }
            
            
            //Graph data
            for i in 0 ... (rates?.count)!-1 {
                
                graph_Data?.append(
                    Post(
                        id: i,
                        post: "\(i+1)",
                        r: CGFloat(rates![i]!),
                        barHeight:  ((rates![i]!) / maxR) * 50 + 5, //80
                        rVr: ratesVr?[i]! ?? 0     //VARR
                    )
                )
            }
        }
        
        
    }
    
    func getMaxRate () -> CGFloat {
        let maxR = processedJson?.maxR == nil || processedJson?.maxR == 0 ? 1 : processedJson?.maxR
        return maxR!
    }
    
}
#endif
