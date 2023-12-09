//
//  dss.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.04.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

@objc
protocol TapTextViewDelegate: AnyObject {
    func tapTextViewDidStartSelection(_ textView: TapTextView)
    func tapTextViewDidFinishSelection(_ textView: TapTextView)
    func tapTextViewShowInfoAlert(_ title: String, _ message: String)
}

extension UIViewController: TapTextViewDelegate {
    func tapTextViewDidStartSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(false,
                                               animated: false)
    }
    
    func tapTextViewDidFinishSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(true,
                                               animated: false)
    }
    
    func tapTextViewShowInfoAlert(_ title: String, _ message: String) {
        let action = UIAlertAction(
            title: "OK",
            style: .default)
        self.simpleAlert(
            title: title,
            message: message,
            btnAction1: action)
    }
}

@IBDesignable
class TapTextView: UITextView {
    var selectionDict = [String:Int]()
    var viewTagCount = Int()
    var tap = UIGestureRecognizer()
    var firstTimeGrouped = false
    
    var tB = UIBarButtonItem()
    
    @IBInspectable
    weak var tagDelegate: TapTextViewDelegate?
    
    func startTagSelection () {
        tap.isEnabled = true
        isEditable = false
        isSelectable = false
        addTappedTagRecognizer()
        tagDelegate?.tapTextViewDidStartSelection(self)
    }

    func addTappedTagRecognizer () {
        tap = UITapGestureRecognizer(target: self,
                                     action: #selector(tapResponse(recognizer:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(tap)
    }
    
    @objc private func tapResponse(recognizer: UITapGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: self)
        let position: CGPoint = CGPoint(x:location.x, y: location.y)
        
        guard 
            let tapPosition: UITextPosition = closestPosition(to: position),
            let textRange: UITextRange = tokenizer.rangeEnclosingPosition(
                tapPosition, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1))
        else {
            return
        }
        
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        let tappedWord: String? = self.text(in:textRange)
        processTappedWord(tappedWord: tappedWord)
        
        /*
        print("number of views after tap:", self.numberOfViewsOnTextView(superView: self))
        print("count:",viewTagCount)
        */
    }

    // MARK: - Selection
    private func processTappedWord(tappedWord: String?) {
        guard let tappedWord else {
            return
        }
 
        if let selectedTag = selectionDict[tappedWord] {
            selectTag(base: tappedWord, tag: selectedTag, isSelected: true)
            selectionDict[tappedWord] = nil
        } else {
            viewTagCount += 1
            selectionDict[tappedWord] = viewTagCount//tappedWord = unique key
            selectTag(base: tappedWord, tag: viewTagCount, isSelected: false)
        }
    }
    
    private func selectTag(base: String, tag: Int, isSelected: Bool) {
        
        //text color
        var textColorAttribute = [NSAttributedString.Key : UIColor]()
        let myString = self.attributedText.mutableCopy() as! NSMutableAttributedString //
        
        //****** Selection
        let pattern = "\\#\(base)\\b" //base //"(\\#[a-zA-Z]+\\b)(?!;)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: self.text, options: [], range: NSMakeRange(0, self.text.count))
 
        for m in matches {
            if isSelected == false {
                textColorAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]//
            
                // *** create a frame view ***
                let range = m.range
                var frame = frameOfTextInRange(range: range)
                frame = frame.insetBy(dx: CGFloat(-1), dy: CGFloat(2)) //Changed
                frame = frame.offsetBy(dx: CGFloat(0), dy: CGFloat(0)) //changed
                let v = UIView(frame: frame)
                v.layer.cornerRadius = v.frame.height / 4 //Initial
                v.tag = tag
                self.insertSubview(v, at: 0)
                //v.backgroundColor = UIColor.systemPink
                v.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                
            } else if isSelected == true {
                textColorAttribute = [NSAttributedString.Key.foregroundColor: .label]//
                
                // *** delete a frame view ***
                self.removeSpecificView(tag: tag)
            }
            myString.addAttributes(textColorAttribute, range: m.range)
        }
        
    self.attributedText = myString.copy() as? NSAttributedString
    }

    //add view
    private func frameOfTextInRange(range:NSRange) -> CGRect {
        let beginning = self.beginningOfDocument
        let start = self.position(from: beginning, offset: range.location)
        let end = self.position(from: start!, offset: range.length)
        let textRange = self.textRange(from: start!, to: end!)
        let rect = self.firstRect(for: textRange!)
        return self.convert(rect, from: self)
    }

    private func numberOfViewsOnTextView(superView: UIView)-> Int{
        var count = 0
        for _ in superView.subviews{count+=1}
        return count
    }

    private func removeSpecificView(tag: Int) {
        subviews
            .filter({$0.tag == tag})
            .forEach({$0.removeFromSuperview()})
    }

    //MARK: - toolbar functions
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
                    processTappedWord(tappedWord: String(tag.dropFirst(1))) //removes "#"
                }
       
                self.scrollRangeToVisible(NSRange(location:0, length:0))
                // print("number of views after tap:", self.numberOfViewsOnTextView(superView: self))
                // print("count:", viewTagCount)
            }
        }
    }
    
    @objc func cleanTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord(tappedWord: tag)
        }
    }
    
    @objc func deleteTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord(tappedWord: tag)
            self.text = self.text.replacingOccurrences(of: "#\(tag)\\b", with: "", options: .regularExpression)
        }
    }
    
    @objc func toolbarInfo(){
        let message = Strings.tapTextViewToolBarDescriptionMessage
        let title = Strings.tapTextViewToolBarDescriptionTitle
        tagDelegate?.tapTextViewShowInfoAlert(title, message)
    }

    //MARK: - Toolbar configuration
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
    
    @objc private func getTag(sender: AnyObject) {
        self.resignFirstResponder()
        self.startTagSelection()
        tB.isEnabled = false
    }
    
    @objc private func doneTagSelection(sender: AnyObject) {
        self.doneTagSelection()
        tB.isEnabled = true
    }
}
