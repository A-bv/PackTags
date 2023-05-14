//
//  GetJson.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12.01.21.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class GenericJSONParser {
    typealias result<T> = (Result<T, Error>) -> Void
    
    class func download(
        fromURLString urlString: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            urlSession.resume()
        }
    }
    
    class func ParseJs2<T: Decodable>(of type: T.Type, data: Data) -> Any? {
        do {
            return try JSONDecoder().decode([T].self, from: data)
        }
        catch {
            print("decode error: ",error)
        }
        return nil
    }
    
    class func ParseJs<T: Decodable>(of type: T.Type, data: Data) -> Any? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("decode error: ",error)
        }
        return nil
    }
    
    /*    class func ParseJs<T: Decodable>(of type: T.Type, data: Data) -> Result<[T], Error> {
     do {
         let decoded = try JSONDecoder().decode([T].self, from: data)
         return .success(decoded)
     } catch let error {
         return .failure(error)
     }
 }*/
}
