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
    @Published var courses: [Course] = [] //PLLLLL
    
    func fetch() {
        let S = Media.self
            GetJson.apiGraphIgBHub (of: S, smartGString: "travel")
            {[weak self](result) in
                let D = result as? Media
                guard let d = D?.data else {return}
                self?.dataMedias = d.compactMap { $0 }
                //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
            }
    }
    
    //PLLLLL
    func fetch2() {
        let S = Course.self
        GetJson.apiGraphIgBHub (of: S, smartGString: "travel")
        {[weak self](result) in
            let D = result as! [Course]
            self?.courses = D
        }
    }
}

#endif
