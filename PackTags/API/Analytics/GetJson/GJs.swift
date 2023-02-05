//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// MARK: - API Calls to get IG Business data
class GetJson: NSObject {
    typealias result<T> = (Result<T, Error>) -> Void
}

extension GetJson {
    class func cURL2<T: Decodable>(
        of type: T.Type,
        from url: String,
        Completion block: @escaping ((Any) -> ()) )
    {
        
        GenericJSONParser.download(fromURLString: url) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
 
                if T.self == Profile.self { saveJsonDataLocally(data: data) } // Necessary for packtags
                
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

extension GetJson {
    class private func saveJsonDataLocally(data: Data) {
        if GetJson.isOkToSaveJsonDataInDir {
            GetJson.saveJsonDataToDir(jsonString: data)
            GetJson.isOkToSaveJsonDataInDir = false
        }
    }
}
