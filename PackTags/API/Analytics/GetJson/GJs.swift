//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

let apiGph_version = "v12.0" //Api graph version

// MARK: - API Calls to get IG Business data
class GetJson: NSObject {
    
    typealias result<T> = (Result<T, Error>) -> Void
    
    class func apiGraphIgBHub<T: Decodable> (of type: T.Type, token:String?, smartGString:String?, Completion block: @escaping ((Any) -> ())) {
        
        guard let token = token else {return}
            
        guard let igBId = UserDefaults.standard.string(forKey: "IgBId") else
        {
            if UserDefaults.standard.bool(forKey: "isCorrectSetup") == false {
                Alerts.setupTroubleShootingAlert(arr: [], presenterVc: nil)
                return
            }
            return
        }

        
        if T.self == Profile.self {
            load_Profile(igBId: igBId, token: token, completion: {
                (profile) in block(profile)
            })
        } else if T.self == Media.self {
            ig_hashtag_search(IgBId: igBId, token: token, s_Hashtag: "travel", Completion: { (media) in
                block(media)
            })
        } else if T.self == Discovery.self {
            print(business_discovery_url(IgBId: igBId, token: token, account: "nike") ?? "nil")
            
        } else if T.self == Course.self {
            //PLLLLL
            ig_hashtag_search2(IgBId: igBId, token: "", s_Hashtag: "travel", Completion: { (course) in
                block(course)
            })
        } else {
            return
        }
    }
}


//Build Urls
extension GetJson {
    
    class func encode_url (url:String) -> String? {
        //URLs must be encoded: "," = "%2C", "{" = "%7B", "}" = "%7D"
        
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else { return nil }
        //No commas
        return encodedUrl.replacingOccurrences(of: ",", with: "%2C")
    }
}
















