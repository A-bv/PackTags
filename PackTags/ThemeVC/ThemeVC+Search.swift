//
//  ThemeVC+toolbar.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

extension ThemeVC {
    func initSearchToolbar() {
        searchView.isHidden = true
        searchCountLabel.isHidden = true //!
    }
}

//Highlight searched words
extension NSAttributedString {
    convenience init(base: String, keyWords: [String], foregroundColor: UIColor, font: UIFont, highlightForeground: UIColor, highlighBackground: UIColor, alpha: CGFloat)
    {
        let baseAttributed = NSMutableAttributedString(string: base, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: foregroundColor])
        
        let range = NSRange(location: 0, length: base.utf16.count)
        for word in keyWords {
            guard let regex = try? NSRegularExpression(pattern: word, options: .caseInsensitive) else {
                continue
            }
            
            regex.matches(in: base, options: .withTransparentBounds, range: range).forEach { baseAttributed.addAttributes(
                [NSAttributedString.Key.backgroundColor: highlighBackground.withAlphaComponent(alpha),
                 NSAttributedString.Key.foregroundColor: highlightForeground],
                range: $0.range) }
        }
        self.init(attributedString: baseAttributed)
    }
}

//Set colors for NSAttributeString extension
extension ThemeVC {
    func highlightColorsForSearchedWords (keyword:[String])
    {
        var color1 = UIColor.black
        if #available(iOS 13.0, *) {color1 = UIColor.label} else {}
        let color2 = themeTextView.tintColor
        let color3 = UIColor.white
        let base = themeTextView.text
        
        self.themeTextView.attributedText = NSAttributedString(
            base: base!,
            keyWords: keyword,
            foregroundColor: color1,
            font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            //font: UIFont.boldSystemFont(ofSize: 17) ,
            highlightForeground: color3,
            highlighBackground: color2!,
            alpha: 0.6)
    }
}



//MARK: - Highlighted tags position
extension ThemeVC {
    
    func getEveryHighlightedWordPosition (word: String) -> [(Int,Int)] {
        var searchedWords = [(Int,Int)]()
        if let mystring = themeTextView.text {
            var searchPosition = mystring.startIndex
            while let range = mystring.range(of: word, options: .caseInsensitive , range: searchPosition..<mystring.endIndex) {
                let startPos = mystring.distance(from: mystring.startIndex, to: range.lowerBound)
                let endPos = mystring.distance(from: mystring.startIndex, to: range.upperBound)
                searchedWords.append((startPos,endPos))
                searchPosition = range.upperBound
            }
        }
        return searchedWords
    }
    
    func getFirstHighlightedWordPosition (word: String) -> Int {
        if let mystring = themeTextView.text {
            if let range = mystring.range(of: word, options: .caseInsensitive) {
                //let startPos = mystring.distance(from: mystring.startIndex, to: range.lowerBound)
                let endPos = mystring.distance(from: mystring.startIndex, to: range.upperBound)
                return endPos
            }
        } else {
            return 0
        }
    return 0
    }
}

//MARK: - searchBar actions
extension ThemeVC {
    
    @IBAction func toolBarDown(_ sender: Any) { //Edit button
        themeTextView.isEditable = true
        searchLockLabel.text = "\u{1F513}"
        view.endEditing(true)
        searchEditButton.isEnabled = false
        themeTextView.becomeFirstResponder()
    }
    
    func startToSearchTags() {
        searchView.isHidden = false
        setCursorPositionAtStart()
        MenuButton.isEnabled = false
        toolBarSearch.becomeFirstResponder()
    }
    
    @IBAction func searchBarOK(_ sender: Any) {
        toolBarSearch.text = ""
        highlightColorsForSearchedWords(keyword: [""])
        searchView.isHidden = true
        themeTextView.isEditable = true
        //setCursorPositionAtStart()
        searchCountLabel.isHidden = true //!
        MenuButton.isEnabled = true
        view.endEditing(true)
    }
    
}

//MARK: - UISearchBarDelegate
extension ThemeVC {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchCountLabel.isHidden = true //!
        searchLockLabel.text = "\u{1F512}"
        searchEditButton.isEnabled = true
        themeTextView.isEditable = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        let values = getEveryHighlightedWordPosition (word: toolBarSearch.text ?? "")
        if toolBarSearch.text?.isEmpty != true {
            searchCountLabel.isHidden = false //!
            searchCountLabel.text = "\(values.count) results" //!
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        highlightColorsForSearchedWords(keyword: [searchText])
        scrollToSubstring (substring: searchText)
    }
}

//MARK: - Cursor
extension ThemeVC {
    func setCursorPositionAtStart (){
        let newPosition = themeTextView.beginningOfDocument
        themeTextView.selectedTextRange = themeTextView.textRange(from: newPosition, to: newPosition)
    }
    
    func setCursorPosition (value:Int) {
        if let newPosition = themeTextView.position(from: themeTextView.beginningOfDocument, offset: value)
        {
            //set cursor position
            themeTextView.selectedTextRange = themeTextView.textRange(from: newPosition, to: newPosition)
        }
    }
}
    
    
//MARK: - Scrolling
extension ThemeVC {
    func scrollToSubstring (substring:String) {
        let value = getFirstHighlightedWordPosition(word: substring)
        //themeTextView.scrollRangeToVisible(NSMakeRange(value, 0)) //first adjustment
        themeTextView.setContentOffset(CGPoint(x: 0,y: 0.5), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [self] in
            self.setCursorPosition(value: value)
            self.ScrollToCursorPosition() //second adjustment
        }
    }
    
    func ScrollToCursorPosition() {
        //coordinates of cursor
        if let cursorPosition = self.themeTextView.selectedTextRange?.start
        {
            let rect: CGRect = self.themeTextView.caretRect(for: cursorPosition)
            let point = CGPoint(x: 0, y: rect.origin.y)
            //print("cursor position:",point)
            self.themeTextView.setContentOffset(point, animated: true)
        }
    }
}

//MARK: - Find pack from show button (PackTableVC)
extension ThemeVC {
    func isScreenLoadedFromShowButton () {
        DispatchQueue.main.async { [self] in
            guard let firstTag = packFromShow.components(separatedBy: " ").first
            else{return}
        
            scrollToSubstring(substring: firstTag+" ")
            
            themeTextView.text = themeTextView.text + "\n" //last for highlight
            highlightColorsForSearchedWords(keyword: ["\(packFromShow)\n"])
        }
    }
}










/*
//Arrow button
extension UIViewController {
    
    func arrowsBtn () -> UIBarButtonItem {
        
        //icons
        var imagesArr = [UIImage()]
        if #available(iOS 13.0, *) {
            imagesArr = [
                UIImage(systemName: "arrow.up")!,
                UIImage(systemName: "arrow.down")!
            ]
        } else {
            imagesArr = [
                UIImage(named: "upAr")!,
                UIImage(named: "downAr")!
            ]
        }
        
        //selector
        let segmentedControl = UISegmentedControl(items: imagesArr)
        
        segmentedControl.addTarget(self, action: #selector(action), for: .valueChanged)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 90, height: 30)
        segmentedControl.isMomentary = true
        
        let segmentBarItem = UIBarButtonItem(customView: segmentedControl)
        return segmentBarItem
    }
    
    @IBAction func action(_ sender: AnyObject) {
        Swift.debugPrint("CustomRightViewController IBAction invoked")
        switch sender.selectedSegmentIndex{
                case 0:
                    print("iOS");
                case 1:
                    print("Android")
                default:
                    break
                }
    }
}
*/

/*
 if let range = themeTextView.text.range(of: searchText) {
    let startPos = themeTextView.text.distance(from: themeTextView.text.startIndex, to: range.lowerBound)
    let endPos = themeTextView.text.distance(from: themeTextView.text.startIndex, to: range.upperBound)
    print(startPos, endPos) // 3 7
 }

 func setScrollPos (searchText: String, offBottom: Int) {
    let scrollPos = getFirstHighlightedWordPosition(word: searchText)
    let scrollToRange = NSMakeRange(scrollPos, offBottom)
    themeTextView.scrollRangeToVisible(scrollToRange)
    setCursorPosition(value: scrollPos)
 }*/
 

