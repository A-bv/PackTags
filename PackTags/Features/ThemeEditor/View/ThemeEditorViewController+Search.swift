//
//  ThemeEditorViewController+toolbar.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI

extension ThemeEditorViewController {
    func initSearchToolbar() {
        searchView.isHidden = true
        searchCountLabel.isHidden = true //!
    }
}

//MARK: - searchBar actions
extension ThemeEditorViewController {
    
    @objc func toolBarDown(_ sender: Any) { //Edit button
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
    
    @objc func searchBarOK(_ sender: Any) {
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
extension ThemeEditorViewController: UISearchBarDelegate {
    private enum Strings {
        static let results = "results".localized()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        themeTextView.highlightColorsForSearchedWords(keyword: [searchText])
        themeTextView.scrollToSubstring (substring: searchText)
        let values = themeTextView.getEveryHighlightedWordPosition (word: toolBarSearch.text ?? "")
        if toolBarSearch.text?.isEmpty == false {
            searchCountLabel.isHidden = false //!
            searchCountLabel.text = "\(values.count) " + Strings.results //!
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
extension ThemeEditorViewController {
    func isScreenLoadedFromShowButton () {
        DispatchQueue.main.async { [self] in
            guard let firstTag = packFromShow.components(separatedBy: " ").first
            else{return}
        
            themeTextView.scrollToSubstring(substring: firstTag+" ")
            
            themeTextView.text = themeTextView.text + "\n" // Last for highlight
            themeTextView.highlightColorsForSearchedWords(keyword: ["\(packFromShow)\n"])
        }
    }
}
