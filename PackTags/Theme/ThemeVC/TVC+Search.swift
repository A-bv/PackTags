//
//  ThemeVC+toolbar.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI

extension ThemeVC {
    func initSearchToolbar() {
        searchView.isHidden = true
        searchCountLabel.isHidden = true //!
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
    
    func startToSearch() {
        searchView.isHidden = false
        themeTextView.setCursorPositionAtStart()
        toolBarSearch.becomeFirstResponder()
    }
    
    @IBAction func searchBarOK(_ sender: Any) {
        toolBarSearch.text = ""
        themeTextView.highlightColorsForSearchedWords(keyword: [""])
        searchView.isHidden = true
        themeTextView.isEditable = true
        searchCountLabel.isHidden = true // !
        isSearchMode = false
        view.endEditing(true)
    }
    
}

//MARK: - UISearchBarDelegate
extension ThemeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        themeTextView.highlightColorsForSearchedWords(keyword: [searchText])
        themeTextView.scrollToSubstring (substring: searchText)
        let values = themeTextView.getEveryHighlightedWordPosition (word: toolBarSearch.text ?? "")
        if toolBarSearch.text?.isEmpty == false {
            searchCountLabel.isHidden = false //!
            searchCountLabel.text = "\(values.count) results" //!
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchLockLabel.text = "\u{1F512}"
        searchEditButton.isEnabled = true
        themeTextView.isEditable = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
}

//MARK: - Find pack from show button (PackTableVC)
extension ThemeVC {
    func isScreenLoadedFromShowButton () {
        DispatchQueue.main.async { [self] in
            guard let firstTag = packFromShow.components(separatedBy: " ").first
            else{return}
        
            themeTextView.scrollToSubstring(substring: firstTag+" ")
            
            themeTextView.text = themeTextView.text + "\n" //last for highlight
            themeTextView.highlightColorsForSearchedWords(keyword: ["\(packFromShow)\n"])
        }
    }
}

/*
extension UITextView {
    //MARK: - toolbar
    func addKeyboardToolBar (){
        let toolbar = UIToolbar()
        self.inputAccessoryView = toolbar
        toolbar.isHidden = false
    }
    
    //Hide textView Keyboard (toolbar function)
    @objc func okkeyboard(sender: AnyObject){
        self.endEditing(true)
    }
}
*/

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
 

