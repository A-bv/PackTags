//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ApiService: NSObject {
    typealias ResultHandler<T> = (Result<T, Error>) -> Void

    // Function to get IG Business data (Analytics and Medias)
    class func fetchDataFromIgApi<T: Decodable>(
        of type: T.Type,
        from url: String,
        completion: @escaping ResultHandler<Any>
    ) {
        GenericJSONParser.download(fromURLString: url) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                if T.self == Profile.self {
                    DocumentDirectory.saveJsonDataLocally(data: data)
                }
                DispatchQueue.main.async {
                    handleSuccessResult(of: T.self, data: data, completion: completion)
                }
            }
        }
    }
   
    private class func handleSuccessResult<T: Decodable>(
        of type: T.Type,
        data: Data,
        completion: @escaping ResultHandler<Any>
    ) {
        if T.self == Profile.self {
            guard let decodedProfile = GenericJSONParser.ParseJs(of: T.self, data: data) as? Profile else {
                return
            }
            completion(.success(decodedProfile))
        } else if T.self == Media.self {
            guard let decodedMedia = GenericJSONParser.ParseJs(of: T.self, data: data) as? Media else {
                return
            }
            let mediaData = decodedMedia.data.compactMap { $0 }
            completion(.success(mediaData))
        } else {
            guard let decodedObject = GenericJSONParser.ParseJs2(of: T.self, data: data) else {
                return
            }
            completion(.success(decodedObject))
        }
    }
}
