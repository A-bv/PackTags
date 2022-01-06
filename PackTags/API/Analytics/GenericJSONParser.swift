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
    
    class func download(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        
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
            //let decodedData: T = try JSONDecoder().decode(T.self, from: data) //PLLL
            let decodedData = try JSONDecoder().decode([T].self, from: data) //PLLL
            return decodedData
        }
        catch {
            print("decode error: ",error)
        }
        return nil
    }
}

extension GenericJSONParser {
    class func cURL2<T: Decodable>(of type: T.Type,
                             from url: String,
                             Completion block: @escaping ((Any) -> ()) ) {
        
        //1
        download(fromURLString: url) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                if T.self == Profile.self {
                    //Necessary for packtags
                    //----------
                    if  GetJson.isOkToSaveJsonDataInDir == true {
                        //Save Json data localy
                        GetJson.saveJsonDataToDir(jsonString: data)
                        GetJson.isOkToSaveJsonDataInDir = false
                    }
                    //----------
                } else {
                    
                }
                DispatchQueue.main.async {
                    guard let decoded = ParseJs2(of: T.self, data: data ) else {return}
                    block(decoded)
                }
            }
        }
    }
    
}




