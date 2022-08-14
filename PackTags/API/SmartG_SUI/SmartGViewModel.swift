//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

class SmartGViewModel: ObservableObject {
    @Published var dataMedias: [DataMedia] = []
    @Published var computedData: [processedSmartGModel] = []
    @Published var topHashtags: [String] = []
    
    func fetch() {
        GetJson.ig_hashtag_search(
            s_Hashtag: "travel",
            Completion: {
                [weak self] (result) in
                guard let result = result as? [DataMedia] else {return}
                self?.dataMedias = result
                self?.processSmartGModel()
            })
        
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}

extension SmartGViewModel {
    func processSmartGModel()
    {
        var processedSmartGModels = [processedSmartGModel]()
        //var hashtagsFullList: [String] = []
        
        for dataMedia in dataMedias {
            guard let hashtags = dataMedia.caption?.detectHashtags() else { return }
            processedSmartGModels.append(processedSmartGModel(hashtags: hashtags))
            //hashtagsFullList += hashtags
        }
    
        self.computedData = processedSmartGModels
        
        // TODO: Finish this
        //self.topHashtags = hashtagsFullList.histogram.sorted { $0.1 > $1.1}.prefix(10).map({ $0.key })
        //print(self.topHashtags)
        
        /*
        self.filteredHashtags = hashtags.joined(separator: " ").detectHashtags().removingDuplicates()
        self.hashtagsHistorigram = hashtags.histogram
        print("Historigram:", hashtagsHistorigram)
         */
    }
}
