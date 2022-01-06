//
//  ViewModel.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import FBSDKLoginKit

//PLLL
struct Course: Hashable, Codable{
    let name: String
    let image: String
}

#if !arch(arm)

@available(iOS 14.0.0, *)
class ViewModel: ObservableObject {
    @Published var dataMedias: [DataMedia] = []
    @Published var courses: [Course] = [] //PLLL
    
    func fetch() {
        let S = Media.self
        if let token = AccessToken.current, !token.isExpired {
            
            GetJson.apiGraphIgBHub (of: S, token: token.tokenString, smartGString: "travel") {[weak self](decodedJson) in

                let D = decodedJson as? Media
                guard let d = D?.data else {return}
                
                self?.dataMedias = d.compactMap { $0 }
                //_ = SmartG_SwiftUI.prJs_HashatgMedia(decodedJson: decodedJson as! Media)
                
            }
        }
    }
    
    //PLLL
    func fetch2() {
        let S = Course.self
        //if let token = AccessToken.current, !token.isExpired {
            
            GetJson.apiGraphIgBHub (of: S, token: "", smartGString: "travel") {[weak self](decodedJson) in
                let D = decodedJson as! [Course]
                self?.courses = D
            }
        //}
    }
}

#endif
