//
//  processJsonAPIGraph.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//



import UIKit

var mode: Int = 0
var rawInsights = true


//MARK: - Process
// Additional operations on the obtained Json data

class ProcessJson: NSObject {
    class func processJsApiGraph (decodedJson: Profile) -> processedStruct
    {
        
        let top = decodedJson
        let n = top.media?.data.count //number of medias
        
        let arrays = buildArraysApiGraph(top: top, n: n)
        
        // 0: likes 1:comments
        let sum0 = (arrays.0 as NSArray).value(forKeyPath: "@sum.floatValue")
        let sum1 = (arrays.1 as NSArray).value(forKeyPath: "@sum.floatValue")
        
        let avg0 = ProcessJson.averageElementsOfArray(a: arrays.likeArray)
        let avg1 = ProcessJson.averageElementsOfArray(a: arrays.commentArray)
        
        let captions = arrays.captions
        
        //VARR
        let times = arrays.times
        
        //Basic
        let usr = top.username
        let isPv = false
        
        //Engagement rates
        let erFw = arrays.engFollowers
        let erReach = arrays.engReach
        let erImpr = arrays.engImpressions
        
        let rates = [erFw, erReach, erImpr]
        
        var avg2 = [CGFloat?]()
        var maxR = [CGFloat?]()
        
        for er in rates {
            avg2.append(ProcessJson.averageElementOfArrayCGFloat(a: er))
            maxR.append(er.reduce(CGFloat.leastNormalMagnitude, { max($0, CGFloat($1)) }))
        }
        
        
        let data = processedStruct(usr: usr, isPv: isPv, sum0: (sum0 as! Int), sum1: (sum1 as! Int), avg0: avg0, avg1: avg1, rates: rates[mode], pTimes: times, avg2: avg2[mode], maxR: maxR[mode], captions: captions)
        
        
        return data
    }
    
    class func buildArraysApiGraph (top:Profile?, n: Int?) -> (
        likeArray: [Int],
        commentArray: [Int],
        engFollowers: [CGFloat],
        times: [Double?],
        captions: [String?],
        engImpressions: [CGFloat],
        engReach: [CGFloat]
    )
    {
        var likeArray = [Int]()
        var commentArray = [Int]()
        var sumLC = [CGFloat]()
        var impressions = [Int]()
        var reach = [Int]()
        var times = [Double?]()
        var captions = [String?]()
        
        var engFollowers  = [CGFloat]()
        var engImpressions  = [CGFloat]()
        var engReach  = [CGFloat]()
        
        if n != nil {
            for i in 0..<n! {
                likeArray.append(top?.media?.data[i]?.like_count ?? 0)
                commentArray.append(top?.media?.data[i]?.comments_count ?? 0)
                captions.append(top?.media?.data[i]?.caption ?? "")
                sumLC.append(CGFloat(top?.media?.data[i]?.insights?.data[2]?.values[0]?.value ?? 0))
                impressions.append(top?.media?.data[i]?.insights?.data[1]?.values[0]?.value ?? 0)
                reach.append(top?.media?.data[i]?.insights?.data[0]?.values[0]?.value ?? 0)
                
                
                //time_stamp
                
                let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                if let stringDate = top?.media?.data[i]?.timestamp {
                    let date = dateFormatter.date(from:(stringDate))
                    times.append(date?.timeIntervalSince1970)
                }
                
            }
            
            
        } else {
            print("buildArraysApiGraph can't compute")
        }
        
        
        if rawInsights == true {
            engFollowers = sumLC.map { ($0) }
        } else {
            //Engagement per Follower
            if top?.followers_count == nil || top?.followers_count == 0 {
                // return 0 when the operation is not possible
                engFollowers = sumLC.map { ($0 * 0) }
                
            } else {
                let f = CGFloat((top?.followers_count)!)
                engFollowers = sumLC.map { ($0 * 100.0 / f) }
            }
        }
        
        if rawInsights == true {
            engImpressions = impressions.map { CGFloat(($0)) }
        } else {
            //Engagement by Impressions
            impressions.indices.forEach {
                if impressions[$0] == 0 { engImpressions.append(0) } //append 0 when Nan
                else {
                    engImpressions.append(sumLC[$0]*100/CGFloat(impressions[$0]))
                }
            }
        }
      
        if rawInsights == true {
            engReach = reach.map { CGFloat(($0)) }
        } else {
            //Engagement by Reach
            reach.indices.forEach {
                if reach[$0] == 0 { engReach.append(0) } //append 0 when Nan
                else {
                    engReach.append(sumLC[$0]*100/CGFloat(reach[$0]))
                }
            }
        }

        
        return (likeArray,          //0
                commentArray,       //1
                engFollowers,       //2
                times,              //3
                captions,           //4
                engImpressions,     //5
                engReach            //6
        )
    }
}







