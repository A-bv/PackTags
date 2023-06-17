//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ApiService: NSObject {
    typealias result<T> = (Result<T, Error>) -> Void

    // Function to get IG Business data (Analytics and Medias)
    class func fetchDataFromIgApi<T: Decodable>(
        of type: T.Type,
        from url: String,
        completion block: @escaping (Any) -> ()
    ) {
        GenericJSONParser.download(fromURLString: url) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                if T.self == Profile.self { DocumentDirectory.saveJsonDataLocally(data: data) }
                DispatchQueue.main.async {
                    handleSuccessResult(of: T.self, data: data, completion: block)
                }
            }
        }
    }
   
    class private func handleSuccessResult<T: Decodable>(
        of type: T.Type,
        data: Data,
        completion block: @escaping (Any) -> ()
    ) {
        if T.Type.self == Profile.Type.self {
            guard let decoded = GenericJSONParser.ParseJs(of: T.self, data: data) else {return}
            block(decoded)
        } else if T.Type.self == Media.Type.self {
            guard let decoded = GenericJSONParser.ParseJs(of: T.self, data: data) else {return}
            let D = decoded as? Media
            guard let d  = D?.data else {return}
            let array = d.compactMap { $0 }
            block(array)
        } else {
            guard let decoded = GenericJSONParser.ParseJs2(of: T.self, data: data) else {return}
            block(decoded)
        }
    }
}
