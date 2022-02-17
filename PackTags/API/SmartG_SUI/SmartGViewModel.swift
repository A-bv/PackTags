//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

#if !arch(arm)
@available(iOS 14.0.0, *)
class SmartGViewModel: ObservableObject {
    @Published var dataMedias: [DataMedia] = []
    @Published var computedData: [processedSmartGModel] = []
    
    func fetch() {
        GetJson.ig_hashtag_search(s_Hashtag: "travel", Completion: {[weak self] (result) in
            guard let result = result as? [DataMedia] else {return}
            self?.dataMedias = result
            self?.processSmartGModel ()
        })
        
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}

@available(iOS 14.0.0, *)
extension SmartGViewModel {
    func processSmartGModel ()
    {
        var processedSmartGModels = [processedSmartGModel]()
        for dataMedia in dataMedias {
            let H = dataMedia.caption?.hashtags()
            if H != nil {
                processedSmartGModels.append(processedSmartGModel(hashtags: H!))
            }
        }
    
        self.computedData = processedSmartGModels.compactMap{$0}
        print(self.computedData)
    }
}
#endif
