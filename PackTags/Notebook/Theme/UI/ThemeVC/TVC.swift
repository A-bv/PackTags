//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    deinit {
        print("deinit ThemeVC")
    }
    
    //MARK: - Properties
    
    //ThemeVC elements **
    @IBOutlet weak var themeTextView: TapTextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var theme: ThemeCD?
    
    var themeImageView = DarkMode.isDarkMode() ? UIImage(named: "Logo-BlackLong") : UIImage(named: "Logo-PurpleLong")
    
    var themeTitle = String()
    
    var isNotNewTheme = false
    // **
    
    //"show" button (PackTableVC) variables 
    var isFromShow = false
    var packFromShow = String()
    
    //Search **
    //Search toolbar variables 1/2
    @IBOutlet weak var toolBarSearch: UISearchBar!
    @IBOutlet weak var searchView: UIStackView!
    @IBOutlet weak var searchEditButton: UIButton!
    @IBOutlet weak var searchLockLabel: UILabel!
    @IBOutlet weak var searchCountLabel: UILabel!
    // **
    
    //Text Recognition in images (iOS < 11) 1/2
    var recognizeText = false
    
    // Processing spinner
    let spinner = UIActivityIndicatorView()
        
    var buttonMenuThemeOptions: UIBarButtonItem {
        return buttonMenu()
    }
    
    var isSearchMode: Bool = false {
        didSet {
            // buttonMenuThemeOptions.isEnabled = !isSearchMode
            // TODO: issue can't disable button in search mode
        }
    }
    
    var numTagsPerPack = QuantityPickerViewModel().numTagsInPack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBarSearch.delegate = self
        
        self.navigationController?.view.tintColor = UITextView.appearance().tintColor
        
        if isNotNewTheme == false {showNameThemeAlert()} else {}
        
        loadbuttons()
        loadEntries ()
        configureTextView()
        
        loadProcessingSpinner()
        
        initSearchToolbar() // Search toolbar 2/2
        
        updateSaveButtonState() // Enable save button if title != empty
        
        if isFromShow == true {
            isScreenLoadedFromShowButton ()
            isFromShow = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK: - Setup
    func updateSaveButtonState() {saveButton.isEnabled = !themeTitle.isEmpty}
    
    private func loadEntries (){
        guard let theme else { return }
        themeTitle = theme.name ?? ""
        
        //Packing by 30 from Core Data on textView
        if let content = theme.content {
            let text = content
            let hashtags = Unique.reorganizeTags(from: text, with: numTagsPerPack)
            themeTextView.text = hashtags
        }
        
        //image
        if let image = theme.image {
            themeImageView = UIImage(data: image)
        }
    }
    
    private func loadProcessingSpinner() {
        spinner.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.view.addSubview(spinner)
    }
    
    private func loadbuttons () {
        navigationItem.rightBarButtonItems = [saveButton, buttonMenuThemeOptions, themeTextView.tapStartBarButtonItem()]
    }
    
    private func configureTextView() {
        themeTextView.delegate = self
        themeTextView.tagDelegate = self
        themeTextView.setPlaceholder()
        themeTextView.addTagSelectorToolBar (vc: self)
        themeTextView.notHiddenByKeyboard()
    }
}

extension ThemeVC {
    //MARK: - UITextViewDelegate
    //Placeholder
    func textViewDidChange(_ textView: UITextView) {
        themeTextView.checkPlaceholder()
    }
}

// Status Bar color
extension ThemeVC {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return  .default
    }
}
