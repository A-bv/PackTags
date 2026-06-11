//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI
import InstagramGraph

class SmartGViewModel: ObservableObject {
    let gateway: any ConnectedInsightsGatewayProtocol

    @Published var dataMedias: [InstagramPost] = []
    @Published var computedData: [SmartGModel] = []
    @Published var topHashtags: [String] = []
    @Published var topHashtagsCount: [Int] = []

    init(gateway: any ConnectedInsightsGatewayProtocol = UnavailableConnectedInsightsGateway()) {
        self.gateway = gateway
    }
}

extension SmartGViewModel {
    func processSmartGModel() {
        var processedSmartGModels = [SmartGModel]()
        var hashtagsFullList: [String] = []
        
        for dataMedia in dataMedias {
            let hashtags = dataMedia.caption?.detectHashtags() ?? []
            processedSmartGModels.append(SmartGModel(hashtags: hashtags))
            hashtagsFullList += hashtags
        }
    
        self.computedData = processedSmartGModels
        
        let hashtagsHistogram = hashtagsFullList.histogram.sorted { $0.1 > $1.1 }.prefix(10)
        self.topHashtags = hashtagsHistogram.map({ $0.key })
        self.topHashtagsCount = hashtagsHistogram.map({ $0.value })
    }
}
