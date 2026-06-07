//
//  DocumentDirectory.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

final class DocumentDirectory {
    static func saveJsonDataLocally(data: Data) {
        saveJsonDataToDir(jsonString: data)
    }
}

//MARK: - General Save/read Json functions into document directory
extension DocumentDirectory {
    static func getJsonDataFromDir() -> Data? {
        let fm = FileManager.default
        if let pathName = fm.urls(
            for: .documentDirectory,in: .userDomainMask)
            .first?.appendingPathComponent("localJsonData"),
           fm.fileExists(atPath: pathName.path)
        {
            do {
                let jsonData = try Data(contentsOf: pathName)
                return jsonData
            } catch {
                print("getJsonDataFromDir error:", error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func saveJsonDataToDir(jsonString: Data?) {
        
        //Saving time
        UserDefaults.standard.set(Date(), forKey: "LastStatsRefresh")
        
        //Saving Json
        if let jsonData = jsonString,
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first
        {
            let url = documentDirectory.appendingPathComponent("localJsonData")
            do {
                try jsonData.write(to: url)
            } catch {
                print("saveJsonDataToDir error:", error.localizedDescription)
            }
        }
    }
}
