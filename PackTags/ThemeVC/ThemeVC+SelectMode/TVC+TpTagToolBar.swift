//
//  TVC+toolBarTagSct.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//removes scroll view problems, when placing views in selection mode
extension ThemeVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        themeTextView.layoutManager.ensureLayout(for:themeTextView.textContainer)
    }
}

extension ThemeVC {
    func addTagSelectorToolBar (){
        addTappedTagRecognizer()
        tap.isEnabled = false
        
        var toolbarIcons = [UIImage?]()
        if #available(iOS 13.0, *) {
            toolbarIcons = [
                                UIImage(systemName: "doc.on.doc"),
                                UIImage(systemName: "scissors"),
                                UIImage(systemName: "square.grid.2x2"),
                                UIImage(systemName: "clear"),
                                UIImage(systemName: "delete.right"),
                                UIImage(systemName: "questionmark.circle.fill")]
        } else {
            toolbarIcons = [UIImage(named:"copy2clipboard"),
                                UIImage(named: "scissors"),
                                UIImage(named: "2x2grid"),
                                UIImage(named: "clear"),
                                UIImage(named: "delete"),
                                UIImage(named: "ImageQuestion")
            ]
        }
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTagSelection))
        //
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //
        
        let copy = UIBarButtonItem(image: toolbarIcons[0], style: .plain, target: self, action: #selector(copyTagSelection))
        
        let cut = UIBarButtonItem(image: toolbarIcons[1], style: .plain, target: self, action: #selector(cutTagSelection))
        
        let group = UIBarButtonItem(image: toolbarIcons[2], style: .plain, target: self, action: #selector(groupTagSelection))
        
        let clean = UIBarButtonItem(image: toolbarIcons[3], style: .plain, target: self, action: #selector(cleanTagSelection))
        
        let delete = UIBarButtonItem(image: toolbarIcons[4], style: .plain, target: self, action: #selector(deleteTagSelection))
        
        let info = UIBarButtonItem(image: toolbarIcons[5], style: .plain, target: self, action: #selector(toolbarInfo))
        info.tintColor = .systemOrange//.withAlphaComponent(0.6)
        
        toolbarItems = [
                        copy,spacer,
                        cut,spacer,
                        group,spacer,
                        clean,spacer,
                        delete,spacer,
                        spacer, info,
                        done]
        
    }
}

extension ThemeVC {
    //enter tag selection
    func startTagSelection() {
        navigationController?.setToolbarHidden(false, animated: false)
        tap.isEnabled = true
        tB.isEnabled = false
        themeTextView.isEditable = false
        themeTextView.isSelectable = false
        
        //cleaning
        let cleanText = Unique.cleanList(t: themeTextView.text, x:theme, shuffle:false)
        themeTextView.text = Unique.packBy(t: cleanText.components(separatedBy:" "))
    }
}

//toolbar for tag selection
extension ThemeVC {
    //exit tag selection
    @objc func doneTagSelection(){
        navigationController?.setToolbarHidden(true, animated: false)
        cleanTagSelection()
        tap.isEnabled = false
        tB.isEnabled = true
        themeTextView.isEditable = true
        themeTextView.isSelectable = true
        firstTimeGrouped = false
    }
    
    //toolBar actions
    @objc func copyTagSelection(){
        let arrayToCopy = (Array(selectionDict.keys)).map { "#" + $0 }
        UIPasteboard.general.string = arrayToCopy.joined(separator: " ")
    }
    
    @objc func cutTagSelection(){
        copyTagSelection()
        deleteTagSelection()
    }
    
    @objc func groupTagSelection(){
        cutTagSelection()
        
        //get from clipboard
        let movedTags = UIPasteboard.general.string
        
        let jump = firstTimeGrouped == false ? "\n\n" : ""
        firstTimeGrouped = true
        
        if movedTags != "" {
            //edit textView's top
            if let position = themeTextView.textRange(from: themeTextView.beginningOfDocument, to: themeTextView.beginningOfDocument) {
                themeTextView.replace(position, withText: "\(movedTags ?? "")" + jump)
            }
        
        
            if let movedTagsArray = movedTags?.components(separatedBy: " ")
            {
                for tag in movedTagsArray {
                    processTappedWord (tappedWord: String(tag.dropFirst(1))) //removes "#"
                }
       
                themeTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    
                print("number of views after tap:",themeTextView.numberOfViewsOnTextView(superView: themeTextView))
                print("count:",viewTagCount)
            }
        }
    }
    
    @objc func cleanTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord (tappedWord: tag)
        }
    }
    
    @objc func deleteTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord (tappedWord: tag)
            themeTextView.text = themeTextView.text.replacingOccurrences(of: "#\(tag)\\b", with: "", options: .regularExpression)
        }
    }
    
    @objc func toolbarInfo(){
        
        let message = """
            
            • Copy •
            • Cut •
            • Group On Top •
            • Clear •
            • Delete •
            
            To undo changes, exit the hashtag
            edition mode with cancel.
            
            You may want to do a save before using this feature.
            
            """
    
        self.simpleAlert(vc: self, title: "Actions on selected hashtags", message: message,btnText: "OK", btnText2: nil)
    }

}

