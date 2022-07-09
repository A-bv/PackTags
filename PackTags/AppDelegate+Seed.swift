//
//  AppDelegate+Extra.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import Foundation

extension AppDelegate {
    func seedData() {
        let fm = FileManager.default
        
        //Destination URL of application folder
        let libURL = fm.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let destFolder = libURL.appendingPathComponent("Application Support").path
        //Or
        //let l1 = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!
        //
        
        //Start URL of Testt
        let folderPath = Bundle.main.resourceURL!.appendingPathComponent("SeedData").path
        
        let fileManager = FileManager.default
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            if let applicationSupportURL = urls.last {
                do{
                    try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
                }
                catch{
                    print(error)
                }
            }
        copyFiles(pathFromBundle: folderPath, pathDestDocs: destFolder)
    }
  

    func copyFiles(pathFromBundle : String, pathDestDocs: String) {
        let fm = FileManager.default
        do {
            let filelist = try fm.contentsOfDirectory(atPath: pathFromBundle)
            let fileDestList = try fm.contentsOfDirectory(atPath: pathDestDocs)

            for filename in fileDestList {
                try FileManager.default.removeItem(atPath: "\(pathDestDocs)/\(filename)")
            }
            
            for filename in filelist {
                try? fm.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("Error info: \(error)")
        }
    }
}
