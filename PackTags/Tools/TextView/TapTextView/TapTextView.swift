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
}

extension UIViewController: TapTextViewDelegate {
    func tapTextViewDidStartSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func tapTextViewDidFinishSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(true, animated: false)
    }
}

@IBDesignable
class TapTextView: UITextView {
    private enum Strings {
        static let tapTextViewToolBarDescriptionMessage = "tapTextViewToolBarDescriptionMessage".localized()
        static let tapTextViewToolBarDescriptionTitle = "Actions on selected hashtags".localized()
        static let infoAlertOk = "OK"
    }
    
    private enum TagSelectionState {
        case selected
        case notSelected
    }

    private enum Constants {
        static let tagViewBackgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        static let cornerRadiusMultiplier: CGFloat = 4.0

        enum Insets {
            static let horizontal: CGFloat = -1
            static let vertical: CGFloat = 2
        }
    }
    
    var selectionDict = [String:Int]()
    var viewTagCount = Int()
    var tap = UIGestureRecognizer()
    var firstTimeGrouped = false
    
    var activateButton = UIBarButtonItem()
    var presentingViewController: UIViewController? = nil
    
    @IBInspectable
    weak var tagDelegate: TapTextViewDelegate?
    
    // MARK: - Activation of TapTextView
    func addTagSelectorToolBar(viewController: UIViewController) {
        presentingViewController = viewController
        guard let presentingViewController else { return }
        presentingViewController.toolbarItems = makeToolbarItems()
    }
    
    func makeTapTextViewButton() -> UIBarButtonItem {
        let img = UIImage(systemName: "hand.point.up.left")!
        activateButton = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(getTag))
        return activateButton
    }
    
    @objc private func getTag() {
        self.resignFirstResponder()
        self.startTagSelection()
        activateButton.isEnabled = false
    }
    
    func doneTagSelection() {
        cleanTagSelection()
        tap.isEnabled = false
        isEditable = true
        isSelectable = true
        firstTimeGrouped = false
        tagDelegate?.tapTextViewDidFinishSelection(self)
    }
    
    private func startTagSelection() {
        tap.isEnabled = true
        isEditable = false
        isSelectable = false
        addTappedTagRecognizer()
        tagDelegate?.tapTextViewDidStartSelection(self)
    }
    
    private func addTappedTagRecognizer() {
        tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapResponse(recognizer:)))

        tap.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(tap)
    }
    
    // MARK: - Selection
    private func makeToolbarItems() -> [UIBarButtonItem] {
        var toolbarIcons = [UIImage?]()
        
        toolbarIcons = [
            UIImage(systemName: "doc.on.doc"),
            UIImage(systemName: "scissors"),
            UIImage(systemName: "square.grid.2x2"),
            UIImage(systemName: "clear"),
            UIImage(systemName: "delete.right"),
            UIImage(systemName: "questionmark.circle.fill")]
        
        let actions: [Selector] = [
            #selector(copyTagSelection),
            #selector(cutTagSelection),
            #selector(groupTagSelection),
            #selector(cleanTagSelection),
            #selector(deleteTagSelection),
            #selector(toolbarInfo)
        ]
        
        var toolbar: [UIBarButtonItem] = []
        
        for (icon, action) in zip(toolbarIcons, actions) {
            let item = makeToolbarItem(image: icon!, action: action)
            
            if icon == toolbarIcons.last {
                item.tintColor = .systemOrange
            }
            toolbar.append(item)

            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolbar.append(spacer)
        }

        toolbar.append(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTagSelection2)))
        
        return toolbar
    }
    
    private func makeToolbarItem(image: UIImage, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }
    
    // MARK: - Selection
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
        print("number of views after tap:", self.subviews.count)
        print("count:",viewTagCount)
        */
    }
    
    private func processTappedWord(tappedWord: String?) {
        guard let tappedWord else {
            return
        }
        
        if let selectedTag = selectionDict[tappedWord] {
            selectTag(base: tappedWord, tag: selectedTag, state: .selected)
            selectionDict[tappedWord] = nil
        } else {
            viewTagCount += 1
            selectionDict[tappedWord] = viewTagCount    //tappedWord = unique key
            selectTag(base: tappedWord, tag: viewTagCount, state: .notSelected)
        }
    }

    private func selectTag(base: String, tag: Int, state: TagSelectionState) {
        var textColorAttribute = [NSAttributedString.Key: UIColor]()
        let myString = self.attributedText.mutableCopy() as! NSMutableAttributedString

        let pattern = "\\#\(base)\\b" //"(\\#[a-zA-Z]+\\b)(?!;)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        let range = NSRange(self.text.startIndex..., in: self.text)
        let matches = regex.matches(in: self.text, options: [], range: range)

        for match in matches {
            switch state {
            case .notSelected:
                textColorAttribute = [.foregroundColor: UIColor.white]

                let frame = frameOfTextInRange(range: match.range)
                let framePadding = frame.insetBy(dx: Constants.Insets.horizontal, dy: Constants.Insets.vertical)

                let view = UIView(frame: framePadding)
                view.layer.cornerRadius = frame.height / Constants.cornerRadiusMultiplier
                view.tag = tag
                self.insertSubview(view, at: 0)
                view.backgroundColor = Constants.tagViewBackgroundColor

            case .selected:
                textColorAttribute = [.foregroundColor: .label]
                self.removeSpecificView(tag: tag)
            }

            myString.addAttributes(textColorAttribute, range: match.range)
        }

        self.attributedText = myString.copy() as? NSAttributedString
    }
    
    private func frameOfTextInRange(range: NSRange) -> CGRect {
        let beginning = beginningOfDocument
        guard
            let start = position(from: beginning, offset: range.location),
            let end = position(from: start, offset: range.length),
            let textRange = textRange(from: start, to: end)
        else {
            return CGRect.zero
        }
        return convert(firstRect(for: textRange), from: self)
    }
    
    private func removeSpecificView(tag: Int) {
        subviews
            .filter({$0.tag == tag})
            .forEach({$0.removeFromSuperview()})
    }
        
    // MARK: - toolBar actions
    @objc private func copyTagSelection(){
        let arrayToCopy = (Array(selectionDict.keys)).map { "#" + $0 }
        UIPasteboard.general.string = arrayToCopy.joined(separator: " ")
    }
    
    @objc private func cutTagSelection(){
        copyTagSelection()
        deleteTagSelection()
    }
    
    @objc private func groupTagSelection(){
        cutTagSelection()
        
        //get from clipboard
        let movedTags = UIPasteboard.general.string
        
        let jump = firstTimeGrouped == false ? "\n\n" : ""
        firstTimeGrouped = true
                
        guard let movedTags, !movedTags.isEmpty else {
            return
        }
        
        if let position = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument) {
            self.replace(position, withText: "\(movedTags)" + jump)
        }
        
        let movedTagsArray = movedTags.components(separatedBy: " ")
        
        for tag in movedTagsArray {
            let tappedWordWithoutHashtag = String(tag.dropFirst(1))
            processTappedWord(tappedWord: tappedWordWithoutHashtag)
        }
        
        self.scrollRangeToVisible(NSRange(location:0, length:0))
        // print("number of views after tap:", self.numberOfViewsOnTextView(superView: self))
        // print("count:", viewTagCount)
        
    }
    
    @objc private func cleanTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord(tappedWord: tag)
        }
    }
    
    @objc private func deleteTagSelection(){
        for tag in selectionDict.keys {
            processTappedWord(tappedWord: tag)
            self.text = self.text.replacingOccurrences(of: "#\(tag)\\b", with: "", options: .regularExpression)
        }
    }
    
    @objc private func toolbarInfo(){
        guard let presentingViewController else { return }
        Alerts.simpleAlert(
            presentingViewController: presentingViewController,
            title: Strings.tapTextViewToolBarDescriptionTitle,
            message: Strings.tapTextViewToolBarDescriptionMessage,
            btnAction1: UIAlertAction(title: Strings.infoAlertOk, style: .default))
    }

    @objc private func doneTagSelection2() {
        self.doneTagSelection()
        activateButton.isEnabled = true
    }
}
