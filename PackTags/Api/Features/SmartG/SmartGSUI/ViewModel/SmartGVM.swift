//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

class SmartGViewModel: ObservableObject {
    @Published var dataMedias: [DataMedia] = []
    @Published var computedData: [SmartGModel] = []
    @Published var topHashtags: [String] = []
    @Published var topHashtagsCount: [Int] = []
}

extension SmartGViewModel {
    func processSmartGModel() {
        var processedSmartGModels = [SmartGModel]()
        var hashtagsFullList: [String] = []
        
        for dataMedia in dataMedias {
            guard let hashtags = dataMedia.caption?.detectHashtags() else {
                return
            }
            processedSmartGModels.append(SmartGModel(hashtags: hashtags))
            hashtagsFullList += hashtags
        }
    
        self.computedData = processedSmartGModels
        
        // TODO: Finish this
        let hashtagsHistogram = hashtagsFullList.histogram.sorted { $0.1 > $1.1 }.prefix(10)
        self.topHashtags = hashtagsHistogram.map({ $0.key })
        self.topHashtagsCount = hashtagsHistogram.map({ $0.value })
        guard let minValue = topHashtagsCount.min() else { return }
        print("Histogram", hashtagsHistogram)
        print(self.topHashtags, minValue)
    }
}
