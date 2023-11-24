//
//  FBLoginVC+op.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

final class ApiService {
    typealias ResultHandler<T> = (Result<T, Error>) -> Void

    static func fetchDataFromUrl<T: Decodable>(
        of type: T.Type,
        from url: String,
        completion: @escaping ResultHandler<Any>
    ) {
        GenericJSONParser.download(fromURLString: url) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                handleSuccessResult(of: T.self, data: data, completion: completion)
            }
        }
    }

    private static func handleSuccessResult<T: Decodable>(
        of type: T.Type,
        data: Data,
        completion: @escaping ResultHandler<Any>
    ) {
        guard let decodedObject = GenericJSONParser.ParseJs2(of: T.self, data: data) else {
            return
        }

        if let profile = decodedObject as? Profile {
            DocumentDirectory.saveJsonDataLocally(data: data)
            completion(.success(profile))
        } else if let media = decodedObject as? Media {
            let mediaData = media.data.compactMap { $0 }
            completion(.success(mediaData))
        } else {
            completion(.success(decodedObject))
        }
    }
}
