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
    
    func fetch() {
        GetJson.ig_hashtag_search(s_Hashtag: "travel", Completion: { (result) in
            guard let result = result as? [DataMedia] else {return}
            self.dataMedias = result
        })
        //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
    }
}

#endif
