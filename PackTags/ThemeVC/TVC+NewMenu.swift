//
//  ThemeVC+Menu2.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI
//MARK: - POP MENU FOR IOS > 14
//UINavigationBarMenuButton
@available(iOS 14.0, *)

extension ThemeVC{
    
    func buttonMenu () -> UIBarButtonItem {
        //MARK: - Buttons
        let editName = UIAction(title: "Rename", image: UIImage(systemName: "tag")) { [weak vc = self] action in //to avoid retained cycles
            vc?.alertTitle()
        }
        
        let editPicture = UIAction(title: "Edit picture", image: UIImage(systemName: "photo.on.rectangle.angled")) { [weak vc = self] action in
            vc?.recognizeText = false
            vc?.setImagePicker()
        }
        
        let textRecon = UIAction(title: "Text Recognition", image: UIImage(systemName: "doc.text.viewfinder")) { [weak vc = self] action in
            vc?.recognizeText = true
            vc?.setImagePicker()
        }
        
        #if !arch(arm)
        let smartGen = UIAction(title: "Smart hashtags", image: UIImage(systemName: "chart.bar.doc.horizontal.fill")) { [weak vc = self] action in
            
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
        #endif
        
        let search = UIAction(title: "Search hashtags", image: UIImage(systemName: "magnifyingglass")) { [weak vc = self] action in
            
            //resign
            vc?.doneTagSelection()
            
            //action
            vc?.startToSearchTags()
        }
        
        let shuffle = UIAction(title: "Shuffle hashtags", image: UIImage(systemName: "shuffle.circle")) { [weak vc = self] action in
            if let textToShuffle = vc?.themeTextView.text {
                let array = Unique.cleanList(t: textToShuffle, x:vc?.theme, shuffle: true).components(separatedBy:" ")
                vc?.themeTextView.text = Unique.packBy(t: array)
            }
        }
        
        
        //MARK: - Menu
        let edit = UIMenu(title: "Edit...",options: .displayInline, children: [editName,editPicture])
        
        #if !arch(arm)
        let htgImport = UIMenu(title: "Edit...",options: .displayInline, children: [textRecon,smartGen])
        #else
        let htgImport = UIMenu(title: "Edit...",options: .displayInline, children: [textRecon])
        #endif
        
        let manage = UIMenu(title: "Manage...",options: .displayInline, children: [shuffle, search])//,select])
        
        let barButtonMenu = UIMenu(title: "",children: [edit,htgImport,manage])
        
        let symbol = UIImage(systemName: "ellipsis.circle")
        let optionsBarItem = UIBarButtonItem(image:symbol, primaryAction: nil, menu: barButtonMenu)
        return optionsBarItem
    }
}
