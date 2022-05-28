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
        print("deinit")
    }
    
    //MARK: - Properties
    
    //ThemeVC elements **
    @IBOutlet weak var themeTextView: TapTextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var themeImageView = DarkMode.isDarkMode() ? UIImage(named: "Logo-BlackLong") : UIImage(named: "Logo-PurpleLong")
    var themeTitle = String()
    var theme: ThemeCD?
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
    
    // SlideUpMenu variables (iOS < 14) 1/3
    var buttonSelectorArray = [#selector(showAlert(sender:)),
                               #selector(selectImageFromPhotoLibrary(sender:)),
                               #selector(searchTags(sender:)),
                               #selector(shuffleTags(sender:))]
    var slideUpMenu: SlideUpMenu!
    
    //MARK: - ThemeVC
    override func viewDidLoad() {
        super.viewDidLoad()
        themeTextView.delegate = self
        toolBarSearch.delegate = self
        
        self.navigationController?.view.tintColor = UITextView.appearance().tintColor
        
        if isNotNewTheme == false {alertTitle()} else {}
        
        loadbuttons()
        loadEntries ()
        
        loadProcessingSpinner()
        
        initSearchToolbar() //Search toolbar 2/2
        
        configureTextView()
        
        updateSaveButtonState() //Enable save button when text
   
        //themeTextView.setupKeyboardNotifications() //Keyboard doesn't hide textView
        
        if isFromShow == true {
            isScreenLoadedFromShowButton ()
            isFromShow = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK: - Setup
    private func updateSaveButtonState() {saveButton.isEnabled = !themeTitle.isEmpty}
    
    private func loadEntries (){
        if let theme = theme {
            themeTitle = theme.name ?? ""
            
            //Packing by 30 from Core Data on textView
            if theme.content != nil {
                let hashtags = Unique.packBy(t: theme.content!.components(separatedBy:" "))
                themeTextView.text = hashtags
            }
            
            //image
            if theme.image == nil {
                print("could not find an image")
            }
            else{
                themeImageView = UIImage(data: theme.image!)
            }
        }
    }
    
    private func loadProcessingSpinner() {
        spinner.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.view.addSubview(spinner)
    }
    
    private func loadbuttons () {
        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItems = [saveButton, buttonMenu(), themeTextView.tapStartBarButtonItem()]
        } else {
            // SlideUpMenu (iOS < 14) 2/3
            self.navigationItem.rightBarButtonItems  = [saveButton, slideUpMenu.MenuButton, themeTextView.tapStartBarButtonItem()]
       }
    }
    
    private func configureTextView() {
        themeTextView.tagDelegate = self
        themeTextView.setPlaceholder()
        themeTextView.addTagSelectorToolBar (vc: self)
    }
    
    //MARK: - UITextViewDelegate
    //Placeholder
    func textViewDidChange(_ textView: UITextView) {
        themeTextView.checkPlaceholder()
    }
    
    //MARK: - Alerts
    //Works with Utility.swift
    func alertTitle () {
        
        let tips = ""
        
        let title = themeTitle.isEmpty == true ? "New Theme" : themeTitle
        let message = themeTitle.isEmpty == true ? tips : "Edit Name"
        let placeholder = themeTitle.isEmpty == true ? "Enter Name" : "Enter New Name"
        
        //Shows alert pop up
        Alerts.alertTitle(targetVC: self, title: title, message: message, placeholder: placeholder) {[weak vc = self] //avoid retained cycle
            (inputName) in
            // continue your logic
            vc?.themeTitle = inputName
            vc?.updateSaveButtonState()
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
