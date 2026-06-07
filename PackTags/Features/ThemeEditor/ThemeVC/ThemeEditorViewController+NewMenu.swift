//
//  ThemeEditorViewController+Menu2.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
// Menu iOS 14+

import UIKit
import SwiftUI

extension ThemeEditorViewController{
    private enum Strings {
        static let rename = "Rename".localized()
        static let editPicture = "Edit picture".localized()
        static let textRecognition = "Text Recognition".localized()
        static let smartHashtags = "Smart hashtags".localized()
        static let searchHashtags = "Search hashtags".localized()
        static let shuffleHashtags = "Shuffle hashtags".localized()
        static let menuSectionEdit = "Edit...".localized()
        static let menuSectionImport = "Import...".localized()
        static let menuSectionManage = "Manage...".localized()
    }
    
    func buttonMenu () -> UIBarButtonItem {
        let editName = UIAction(
            title: Strings.rename,
            image: UIImage(systemName: "tag")
        ) { [weak vc = self] action in
            vc?.showNameThemeAlert()
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
        
        /*
        let smartGen = UIAction(
            title: Strings.smartHashtags,
            image: UIImage(systemName: "chart.bar.doc.horizontal.fill")
        ) { [weak self] action in
            let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
            if isCorrectSetup {
                self?.showSmartGScreen()
            } else {
                self?.showFBLoginScreenFromThemeEditorViewController()
            }
        }*/
        
        let search = UIAction(
            title: Strings.searchHashtags,
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak vc = self] action in
            vc?.startToSearch()
            vc?.isSearchMode = true
        }
        
        let shuffle = UIAction(
            title: Strings.shuffleHashtags,
            image: UIImage(systemName: "shuffle.circle")
        ) { [weak self] action in
            guard let self, let textToShuffle = self.themeTextView.text else { return }
            self.themeTextView.text = self.viewModel.shuffleContent(rawText: textToShuffle)
        }
        
        let edit = UIMenu(
            title: Strings.menuSectionEdit,
            options: .displayInline,
            children: [editName,editPicture])
        
        let htgImport = UIMenu(
            title: Strings.menuSectionImport,
            options: .displayInline,
            children: [textRecon]) //[textRecon,smartGen])
        
        let manage = UIMenu(
            title: Strings.menuSectionManage,
            options: .displayInline,
            children: [shuffle, search])
        
        let barButtonMenu = UIMenu(title:"", children: [edit,htgImport,manage])
        
        let symbol = UIImage(systemName: "ellipsis.circle")
        
        let optionsBarItem = UIBarButtonItem(image:symbol, primaryAction: nil, menu: barButtonMenu)
        
        return optionsBarItem
    }
}

extension ThemeEditorViewController {
    /*
    private func showSmartGScreen() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let hostingController = UIHostingController(rootView: SmartGViewContainer(dataController: dataController))
        hostingController.modalPresentationStyle = .overFullScreen
        self.present(hostingController, animated: true, completion: nil)
    }*/
    
    private func showFBLoginScreenFromThemeEditorViewController() {
        let viewController = ConnectedInsightsModule().makeViewController(for: .setup)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
    }
}
