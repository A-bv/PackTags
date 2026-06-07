//
//  Import.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// Analytics
extension AnalyticsSUIViewModel {
    // 1. local import (called when refreshing data without web)
    func getJsonFromDir () {
        DispatchQueue.main.async { [weak self] in
            guard let jsonData = DocumentDirectory.getJsonDataFromDir() else { return } //data
            guard
                let profileJson = GenericJSONParser.ParseJs(
                    of: Profile.self,
                    data: jsonData) as? Profile
            else { return }
     
            DispatchQueue.main.async{ [weak self] in
                self?.load(profileJson: profileJson)
            }
        }
    }
    
    // 2. Api import
    func getOnlineJsonAPIGraph () {
        analyticsDataProvider.loadProfileForAnalytics(
            completion: { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let profileJson):
                        self?.load(profileJson: profileJson)
                    case .failure(let error):
                        print("Error loading analytics profile: \(error)")
                    }
                }
            })
    }
    
    private func load(profileJson: Profile) {
        jsonOfficial = profileJson
        processedJson = DataTransformer.ProfileDataTransformer.transform(response: profileJson)
        // QQQ

        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.processedJson = self?.fakeProcessedJson0()
            self?.updateData()
        }*/
        updateData()
    }
    
    private func updateData() {
        fillGraphData()
        fillOverviewSectionData()
    }
    
    private func fillGraphData() {
        guard let rates = processedJson?.rates, !rates.isEmpty else {
            print("No rates available.")
            return
        }
        
        let maxR = getMaxRate()
        barChartData.removeAll()
        
        for i in 0 ... rates.count - 1 {
            barChartData.append(
                BarChartPost(
                    id: i,
                    post: "\(i+1)",
                    rate: CGFloat(rates[i]!),
                    barHeight:  ((rates[i]!) / maxR) * 50 + 5)) //80
        }
    }
    
    private func fillOverviewSectionData() {
        guard let rates = processedJson?.rates, !rates.isEmpty else {
            return
        }

        overviewSectionData[0].value = processedJson?.avg0 ?? "0"
        overviewSectionData[1].value = processedJson?.avg1 ?? "0"

        circlesData[1].value = CGFloat(rates[0] ?? 0)
        circlesData[1].maxValue = getMaxRate()

        let avgEngagement: CGFloat = CGFloat(processedJson?.avg2 ?? 0)
        circlesData[0].value = avgEngagement
        circlesData[0].maxValue = avgEngagement
    }
    
    private func getMaxRate() -> CGFloat {
        let max = processedJson?.maxR
        return (max == nil || max == 0 ? 1 : max)!
    }
}
