//
//  TVC+toolBarTagSct.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12/02/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//toolbar functions
extension TapTextView {
    private enum Strings {
        static let tapTextViewToolBarDescriptionMessage = "tapTextViewToolBarDescriptionMessage".localized()
        static let tapTextViewToolBarDescriptionTitle = "Actions on selected hashtags".localized()
    }
    
    @objc func doneTagSelection() {
        cleanTagSelection()
        tap.isEnabled = false
        isEditable = true
        isSelectable = true
        firstTimeGrouped = false
        tagDelegate?.tapTextViewDidFinishSelection(self)
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
            if let position = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument) {
                self.replace(position, withText: "\(movedTags ?? "")" + jump)
            }
        
        
            if let movedTagsArray = movedTags?.components(separatedBy: " ")
            {
                for tag in movedTagsArray {
                    processTappedWord (tappedWord: String(tag.dropFirst(1))) //removes "#"
                }
       
                self.scrollRangeToVisible(NSRange(location:0, length:0))
                // print("number of views after tap:", self.numberOfViewsOnTextView(superView: self))
                // print("count:", viewTagCount)
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
            self.text = self.text.replacingOccurrences(of: "#\(tag)\\b", with: "", options: .regularExpression)
        }
    }
    
    @objc func toolbarInfo(){
        let message = Strings.tapTextViewToolBarDescriptionMessage
        let title = Strings.tapTextViewToolBarDescriptionTitle
        tagDelegate?.tapTextViewShowInfoAlert(title, message)
    }
}

//Toolbar configuration
extension TapTextView {
    func addTagSelectorToolBar (vc : UIViewController){
        var toolbarIcons = [UIImage?]()
        
        toolbarIcons = [
            UIImage(systemName: "doc.on.doc"),
            UIImage(systemName: "scissors"),
            UIImage(systemName: "square.grid.2x2"),
            UIImage(systemName: "clear"),
            UIImage(systemName: "delete.right"),
            UIImage(systemName: "questionmark.circle.fill")]
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTagSelection(sender:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let copy = UIBarButtonItem(image: toolbarIcons[0], style: .plain, target: self, action: #selector(copyTagSelection))
        
        let cut = UIBarButtonItem(image: toolbarIcons[1], style: .plain, target: self, action: #selector(cutTagSelection))
        
        let group = UIBarButtonItem(image: toolbarIcons[2], style: .plain, target: self, action: #selector(groupTagSelection))
        
        let clean = UIBarButtonItem(image: toolbarIcons[3], style: .plain, target: self, action: #selector(cleanTagSelection))
        
        let delete = UIBarButtonItem(image: toolbarIcons[4], style: .plain, target: self, action: #selector(deleteTagSelection))
        
        let info = UIBarButtonItem(image: toolbarIcons[5], style: .plain, target: self, action: #selector(toolbarInfo))
        info.tintColor = .systemOrange//.withAlphaComponent(0.6)
        
        vc.toolbarItems = [
                        copy,spacer,
                        cut,spacer,
                        group,spacer,
                        clean,spacer,
                        delete,spacer,
                        spacer, info,
                        done]
    }
    
    func tapStartBarButtonItem () -> UIBarButtonItem {
        let img = UIImage(systemName: "hand.point.up.left")!
        tB = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(getTag(sender:)))
        return tB
    }
    
    @objc func getTag(sender: AnyObject) {
        self.resignFirstResponder()
        self.startTagSelection()
        tB.isEnabled = false
    }
    
    @objc func doneTagSelection(sender: AnyObject) {
        self.doneTagSelection()
        tB.isEnabled = true
    }
}

