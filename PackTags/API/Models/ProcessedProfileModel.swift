//
//  Data_Struct.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 03/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

struct ProcessedProfileModel {
    
    let usr: String?                //. Basic: username
    let isPrivateProfile: Bool?                 //. Basic: is private?
    let postsCount: Int?            //. Basic: post count
    
    let sum0: Int?                  //0. Total likes
    let sum1: Int?                  //1. Total comments
    let avg0: String?               //2. Avg likes
    let avg1: String?               //3. Avg comments
    let rates: ([CGFloat?])         //4. Engagement rates
    let pTimes: [Double?]           //5. Posting times
    let avg2: CGFloat?              //6. Avg Engagement
    let maxR: CGFloat?              //7. Max Engagement
    let captions: [String?]         //8. Caption
    
    init(usr: String? = nil,
         isPv: Bool? = nil,
         sum0: Int? = nil,
         sum1: Int? = nil,
         avg0: String? = nil,
         avg1: String? = nil,
         rates: ([CGFloat?]) = ([nil]),
         pTimes: [CDouble?] = [nil],
         avg2: CGFloat? = nil,
         maxR: CGFloat? = nil,
         captions: [String?] = [nil]
         ) {
        
        self.usr = usr
        self.isPrivateProfile = isPv
        self.sum0 = sum0
        self.sum1 = sum1
        self.avg0 = avg0
        self.avg1 = avg1
        self.rates = rates
        self.pTimes = pTimes
        self.avg2 = avg2
        self.maxR = maxR
        self.captions = captions
        self.postsCount = rates.count
    }
}

struct subProcessedProfileModel {
    let likeArray: [Int]
    let commentArray: [Int]
    let engFollowers: [CGFloat]
    let times: [Double?]
    let captions: [String?]
    let engImpressions: [CGFloat]
    let engReach: [CGFloat]
}
