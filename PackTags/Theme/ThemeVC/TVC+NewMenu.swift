//
//  ThemeVC+Menu2.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
// Menu iOS 14+

import UIKit
import SwiftUI

extension ThemeVC{
    private enum Strings {
        static let rename = "Rename"
        static let editPicture = "Edit picture"
        static let textRecognition = "Text Recognition"
        static let smartHashtags = "Smart hashtags"
        static let searchHashtags = "Search hashtags"
        static let shuffleHashtags = "Shuffle hashtags"
    }
    
    func buttonMenu () -> UIBarButtonItem {
        let editName = UIAction(
            title: Strings.rename,
            image: UIImage(systemName: "tag")
        ) { [weak vc = self] action in
            vc?.showGiveThemeNameAlert()
        }
        
        let editPicture = UIAction(
            title: Strings.editPicture,
            image: UIImage(systemName: "photo.on.rectangle.angled")
        ) { [weak vc = self] action in
            vc?.recognizeText = false
            vc?.setImagePicker()
        }
        
        let textRecon = UIAction(
            title: Strings.textRecognition,
            image: UIImage(systemName: "doc.text.viewfinder")
        ) { [weak vc = self] action in
            vc?.recognizeText = true
            vc?.setImagePicker()
        }
        
        let smartGen = UIAction(
            title: Strings.smartHashtags,
            image: UIImage(systemName: "chart.bar.doc.horizontal.fill")
        ) { [weak vc = self] action in
            
            guard let blockNavigation = vc?.shouldShowFBLogin() else {
                vc?.showFBLoginScreen()
                return
            }
            
            if blockNavigation {
                return
            } else {
                let hostingController = UIHostingController(rootView: SmartG_SwiftUI())
                hostingController.modalPresentationStyle = .overFullScreen
                vc?.present(hostingController, animated: true, completion: nil)
            }
        }
        
        let search = UIAction(
            title: Strings.searchHashtags,
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak vc = self] action in
            vc?.themeTextView.doneTagSelection()
            vc?.startToSearch()
            vc?.isSearchMode = true
        }
        
        let shuffle = UIAction(
            title: Strings.shuffleHashtags,
            image: UIImage(systemName: "shuffle.circle")
        ) { [weak vc = self] action in
            if let textToShuffle = vc?.themeTextView.text {
                let array = Unique.cleanList(t: textToShuffle, x:vc?.theme, shuffle: true).components(separatedBy:" ")
                vc?.themeTextView.text = Unique.packBy(t: array)
            }
        }
        
        let edit = UIMenu(title: "Edit...",options: .displayInline, children: [editName,editPicture])
        
        let htgImport = UIMenu(title: "Edit...",options: .displayInline, children: [textRecon,smartGen])
        
        let manage = UIMenu(title: "Manage...",options: .displayInline, children: [shuffle, search])
        
        let barButtonMenu = UIMenu(title: "",children: [edit,htgImport,manage])
        
        let symbol = UIImage(systemName: "ellipsis.circle")
        
        let optionsBarItem = UIBarButtonItem(image:symbol, primaryAction: nil, menu: barButtonMenu)
        
        return optionsBarItem
    }
}
