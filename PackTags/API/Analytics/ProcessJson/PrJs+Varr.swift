//
//  ProcessJson+Varr.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 19/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
//MARK: - Varr core

struct engagementVariations {
    let avg2Vr: CGFloat?            //8. Variation Avg Engagement
    let ratesVr: [CGFloat?]         //9. Variations rates
    
    init(
        avg2Vr: CGFloat? = nil,
        ratesVr: [CGFloat?] = [nil]
    ) {
        self.avg2Vr = avg2Vr
        self.ratesVr = ratesVr
    }
}

extension ANewVCDataSUI {
    //VARR Entry
    func getEngagementVariations(isFromSave: Bool) {
        
        if isFromSave == true {
            self.engagementVariations = ProcessJson.getSavedVariationsForLocal()
        } else {
            if let pJ = self.processedJson {
                self.engagementVariations = ProcessJson.buildEngagementRatesVariations(pj: pJ)
                ProcessJson.saveEngagementRates(avg2: pJ.avg2, rates: pJ.rates, times: pJ.pTimes)
            }
        }
    }
}

extension ProcessJson {
    class func removeAllSavedVarData () {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Historical engagement rates")
        defaults.removeObject(forKey: "Historical average engagement rate")
        defaults.removeObject(forKey: "Local Historical ER")
        defaults.removeObject(forKey: "Local Historical AER")
    }
    
    // 1.   -> Entry
    class func saveEngagementRates (avg2: CGFloat?, rates: [CGFloat?], times: [Double?]) {
        let defaults = UserDefaults.standard
        defaults.set(rates, forKey: "Historical engagement rates")
        defaults.set(avg2, forKey: "Historical average engagement rate")
        defaults.set(times, forKey: "Post times")
    }
    
    // 2.   Exit ->
    class func getSavedVariationsForLocal() -> engagementVariations? {
        let defaults = UserDefaults.standard
           
        if let ratesVr = defaults.object(forKey: "Local Historical ER") as? [CGFloat],
            let avg2r = defaults.object(forKey: "Local Historical AER") as? CGFloat {
                let data = engagementVariations( avg2Vr: avg2r , ratesVr: ratesVr)
                return data
            
        }
        return nil
        
    }

    // Operations
    class func buildEngagementRatesVariations (pj:processedProfileModel) -> engagementVariations? {
        
        let defaults = UserDefaults.standard
        
        // 0.
        //Can't compute variations if there is no rates
        if pj.rates == Optional([]) {
            return nil
        }
        
        //1.
        //If there is a changement in the posts, then reset variations
        if let savedTimes = defaults.object(forKey: "Post times") as? [Double?] {
            
            if savedTimes != pj.pTimes {
                
                //print("current fetch Times", pj.pTimes.map { Date(timeIntervalSince1970: $0!)} )
                //print("saved Times", savedTimes.map { Date(timeIntervalSince1970: $0!)} )
                
                removeAllSavedVarData()
                print("reset times")
            }
        }
        
        //2.
        let noOpArr = pj.rates.compactMap { $0 ?? 0 } // array with no optionals
        let vr = computeVariaton(avg2: pj.avg2 ?? 0, rates: noOpArr)
        
        //3.
        let data = engagementVariations(avg2Vr: vr.0, ratesVr: vr.1)
        
        //4. Saves VARR for local uses (Dir)
        defaults.set(vr.0, forKey: "Local Historical ER")    //avg2Vr
        defaults.set(vr.1, forKey: "Local Historical AER")   //ratesVr
        
        return data
    }
    
    class func computeVariaton (avg2:CGFloat, rates: [CGFloat]) -> (CGFloat, [CGFloat])  {
        let defaults = UserDefaults.standard
        
        var avg2Vr = CGFloat()
        var ratesVr = [CGFloat()]
        let count = rates.count
        
        avg2Vr = 0
        ratesVr = [CGFloat]( repeating: 0.0, count: count )
        
        //Checks refreshed data. Return 0's if odd values.
        if avg2 == 0 || rates == [] {
            return (avg2Vr, ratesVr)
        }
        
        
        //Checks saved data. Computate rates if values are ok.
        if let histAvg2 = defaults.object(forKey: "Historical average engagement rate") as? CGFloat {
            
            //checks valid histAvg2
            if histAvg2 != 0 {
                avg2Vr = ((avg2 - histAvg2) / histAvg2) * 100
            }
        }
        
        
        if let histRates = defaults.object(forKey: "Historical engagement rates") as? [CGFloat] {
            //checks valid histRates
            if histRates != [] {
                let ratesVrDiff = zip(rates, histRates).map { $0 - $1 }
                ratesVr = zip(ratesVrDiff, histRates).map { $0 * 100 / $1}
            }
   
         
        //returs 0's if no previous data
        } else {
            ratesVr = [CGFloat]( repeating: 0.0, count: count )
        }
        
        return (avg2Vr, ratesVr)
    }
}
