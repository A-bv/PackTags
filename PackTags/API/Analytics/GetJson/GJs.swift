//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

let apiGph_version = "v12.0" //Api graph version
let fbToken = UserDefaults.standard.string(forKey: "fbToken") ?? ""// "17841446788403615&limit=25&access_token=***REMOVED***"
let igBId = UserDefaults.standard.string(forKey: "IgBId") ?? ""// "17841446788403615"

// MARK: - API Calls to get IG Business data
class GetJson: NSObject {
    typealias result<T> = (Result<T, Error>) -> Void
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

extension GetJson {
    class func cURL2<T: Decodable>(of type: T.Type,
                             from url: String,
                             Completion block: @escaping ((Any) -> ()) ) {
        
        GenericJSONParser.download(fromURLString: url) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                //Necessary for packtags
                //----------
                if T.self == Profile.self {
                    if  GetJson.isOkToSaveJsonDataInDir == true {
                        //Save Json data localy
                        GetJson.saveJsonDataToDir(jsonString: data)
                        GetJson.isOkToSaveJsonDataInDir = false
                    }
                }
                //----------
                
                DispatchQueue.main.async {
                    if T.Type.self == Profile.Type.self {
                        guard let decoded = GenericJSONParser.ParseJs(of: T.self, data: data ) else {return}
                        block(decoded)
                    } else if T.Type.self == Media.Type.self {
                        guard let decoded = GenericJSONParser.ParseJs(of: T.self, data: data ) else {return}
                        let D = decoded as? Media
                        guard let d  = D?.data else {return}
                        let array = d.compactMap { $0 }
                        block(array)
                    } else {
                        guard let decoded = GenericJSONParser.ParseJs2(of: T.self, data: data ) else {return}
                        block(decoded)
                    }
                }
            }
        }
    }
}













