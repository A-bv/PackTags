//
//  GetJson+Dir.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//MARK: - Save/read Json to document directory
extension GetJson {
    
    static var isOkToSaveJsonDataInDir = false
    
    
    class func getJsonDataFromDir() -> Data? {
        let fm = FileManager.default
        let pathName = fm.urls(for: .documentDirectory,in: .userDomainMask)
            .first?.appendingPathComponent("localJsonData")
        
        if pathName != nil {
            if fm.fileExists(atPath: pathName!.path){
                do {
                    let jsonData = try Data(contentsOf: pathName!)
                    //print(try String(contentsOf: pathName!)) //prints Json
                    return jsonData
                } catch {
                    print("getJsonDataFromDir error:", error)
                }
            }
        }
        return nil
    }
    
    class func saveJsonDataToDir (jsonString: Data?) {
        
        //Saving time
        UserDefaults.standard.set(Date(), forKey: "LastStatsRefresh")
        
        //Saving Json
        if let jsonData = jsonString,
            let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                             in: .userDomainMask).first
        {
            let url = documentDirectory.appendingPathComponent("localJsonData")
            do {
                try jsonData.write(to: url)
                //print(try String(contentsOf: url)) //prints Json
            } catch {
                print("saveJsonDataToDir error:", error.localizedDescription)
            }
        }
        
        print("Json saved in document directory")
    }
    
}
