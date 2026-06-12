// Menu iOS 14+

import UIKit
import TextSearchKit

extension ThemeEditorViewController{
    private enum Strings {
        static let rename = "Rename".localized()
        static let editPicture = "Edit picture".localized()
        static let textRecognition = "Text Recognition".localized()
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

        let search = UIAction(
            title: Strings.searchHashtags,
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak vc = self] action in
            vc?.searchBar.beginSearch()
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
            children: [textRecon])
        
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
