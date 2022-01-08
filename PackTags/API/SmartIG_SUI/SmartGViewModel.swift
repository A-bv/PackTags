//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import FBSDKLoginKit

#if !arch(arm)
@available(iOS 14.0.0, *)
class SmartGViewModel: ObservableObject {
    @Published var dataMedias: [DataMedia] = []
    @Published var courses: [Course] = [] //PLLLLL
    
    func fetch() {
        let S = Media.self
        if let token = AccessToken.current, !token.isExpired {
            
            GetJson.apiGraphIgBHub (of: S, token: token.tokenString, smartGString: "travel")
            {[weak self](result) in

                let D = result as? Media
                guard let d = D?.data else {return}
                self?.dataMedias = d.compactMap { $0 }
                //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
                
            }
        }
    }
    
    //PLLLLL
    func fetch2() {
        
        //if let token = AccessToken.current, !token.isExpired {
        
        let S = Course.self
        GetJson.apiGraphIgBHub (of: S, token: "", smartGString: "travel")
        {[weak self](result) in
            
                let D = result as! [Course]
                self?.courses = D
        }
        
        /* //FETCH 3
        let igBId = ""
        GetJson.ig_hashtag_search2(IgBId: igBId, token: "", s_Hashtag: "travel", Completion: { [weak self] (course) in
            let D = course as! [Course]
            self?.courses = D
        })
        */
       
        /*
        let S = Course.self
        GetJson.apiGraphIgBHub (of: S, token: "", smartGString: "travel") {[weak self](decodedJson) in
                let D = decodedJson as! [Course]
                self?.courses = D
        }*/
            
        //}
    }
}

#endif
