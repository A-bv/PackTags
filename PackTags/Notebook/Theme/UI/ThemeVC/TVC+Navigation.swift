//
//  TVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 28.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeVC {
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         guard let identifier = segue.identifier else { return }
         if identifier == "cancel" { return }
     
         //Text treatment (no duplicates, no wrong tags)
         let text = Unique.cleanTagList(
            rawText: themeTextView.text,
            coreDataModel:theme,
            shuffle: false)
         
         //Downsampling
         let image = themeImageView?.jpegData(compressionQuality: 0.8)
         let thumbnail = themeImageView?.resized(
            to: CGSize(
                width: 135.333,
                height: 135.333)
         ).jpegData(compressionQuality: 0.8)
         //135.33 = tableView.frame.size.height/6
         
         //OPTIONAL: Reorder tableView
         let index = CoreDataHelper.getRecordsCount()
         
         switch identifier {
             case "save" where theme != nil:
                 theme?.name = themeTitle
                 theme?.content = text
                 theme?.image = image
                 theme?.thumbnail = thumbnail
                 CoreDataHelper.saveTheme()
                 
                 //Storekit (app review)
                 StoreKitHelper.displayStoreKit()
                 
             case "save" where theme == nil:
                 let newTheme = CoreDataHelper.newTheme()
                 newTheme.name = themeTitle
                 newTheme.content = text
                 newTheme.image = image
                 newTheme.thumbnail = thumbnail
                 newTheme.orderIndex = index
                 CoreDataHelper.saveTheme()
             default:
                 print("unexpected segue identifier")
             }
     }
     
     @IBAction func cancel(_ sender: UIBarButtonItem)
     {
          let isPresentingInAddThemeMode = presentingViewController is UINavigationController
          if isPresentingInAddThemeMode {
              dismiss(animated: true, completion: nil)
             performSegue(withIdentifier: "cancel", sender: self)
          } else if let owningNavigationController = navigationController {
              owningNavigationController.popViewController(animated: false)
          } else {
              fatalError("func cancel")
          }
     }
}
