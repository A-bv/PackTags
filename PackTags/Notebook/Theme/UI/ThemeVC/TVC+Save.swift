//
//  TVC+Save.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeVC {
    private enum Constants {
        static let thumbnailResizedSize = CGSize(width: 135.333, height: 135.333)
        static let jpegCompressionQuality = CGFloat(0.8)
    }

    func handleSelectedThemeData() {
        //Text treatment (no duplicates, no wrong tags)
        let text = Unique.cleanTagList(
           rawText: themeTextView.text,
           coreDataModel:theme,
           shuffle: false)
        
        //Downsampling
        let image = themeImageView?.jpegData(
            compressionQuality: Constants.jpegCompressionQuality)
        let thumbnail = themeImageView?.resized(
            to: Constants.thumbnailResizedSize).jpegData(
                compressionQuality: Constants.jpegCompressionQuality)
        
        //OPTIONAL: Reorder tableView
        let index = CoreDataHelper.getRecordsCount()
        
        if theme != nil {
            theme?.name = themeTitle
            theme?.content = text
            theme?.image = image
            theme?.thumbnail = thumbnail
            CoreDataHelper.saveTheme()
            
            //Storekit (app review)
            StoreKitHelper.displayStoreKit()
        } else if theme == nil {
            let newTheme = CoreDataHelper.newTheme()
            newTheme.name = themeTitle
            newTheme.content = text
            newTheme.image = image
            newTheme.thumbnail = thumbnail
            newTheme.orderIndex = index
            CoreDataHelper.saveTheme()
        }
    }
}
