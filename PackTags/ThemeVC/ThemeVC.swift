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
    
    //Processing spinner
    let spinner = UIActivityIndicatorView()
        
    //SlideUpMenu variables (iOS < 14) 1/4
    var transparentView = UIView()
    var tableViewMenu1 = UITableView()
    let menu1Height: CGFloat = 200
    var MenuButton = UIBarButtonItem()
    var buttonLabelArray = ["Edit name","Edit picture","Search hashtags","Shuffle hashtags"]
        //, "Select hastags"]
    var buttonIconsArray = ["titleTag","imageLib","mglassIcon","shuffle"]
        //,"tap"]
    
    var buttonSelectorArray = [#selector(showAlert(sender:)),
                               #selector(selectImageFromPhotoLibrary(sender:)),
                               #selector(searchTags(sender:)),
                               #selector(shuffleTags(sender:))
    ]
                               //,#selector(getTag(sender:))]
    
    
    //MARK: - ThemeVC
    override func viewDidLoad() {
        super.viewDidLoad()
        themeTextView.delegate = self
        toolBarSearch.delegate = self
        
        //view color
        self.navigationController?.view.tintColor = UITextView.appearance().tintColor
        //self.view.backgroundColor = bkgdColor
        
        if isNotNewTheme == false {alertTitle()} else {}
        
        loadbuttons()
        loadEntries ()
        
        loadProcessingSpinner()
        
        initSearchToolbar() //Search toolbar 2/2
        
        initMenu() //SlideUpMenu (iOS < 14) 2/4
        
        configureTextView()
        
        updateSaveButtonState() //Enable save button when text
   
        setupKeyboardNotifications() //Keyboard doesn't hide textView
        
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
        //Menu
        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItems = [saveButton, buttonMenu(), themeTextView.tapStartBarButtonItem()]
        } else {
            //SlideUpMenu (iOS < 14) 3/4
            MenuButton = UIBarButtonItem(image: UIImage(named: "ellipsis.circle"), style: .plain, target: self, action: #selector(showMenu(sender:)))
            self.navigationItem.rightBarButtonItems  = [saveButton, MenuButton, themeTextView.tapStartBarButtonItem()]
       }
    }
    
    private func configureTextView() {
        themeTextView.tagDelegate = self
        themeTextView.setPlaceholder()
        themeTextView.addTagSelectorToolBar (vc: self)
    }
   
    
   //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "cancel" {return}
    
        //Text treatment (no duplicates, no wrong tags)
        let text = Unique.cleanList(t: themeTextView.text, x:theme, shuffle: false)
        
        //Downsampling
        let image = themeImageView?.jpegData(compressionQuality: 0.8)
        let thumbnail = themeImageView?.resized(to: CGSize(width: 135.333,height: 135.333)).jpegData(compressionQuality: 0.8)
        //135.33 = tableView.frame.size.height/6
        
        //OPTIONAL: Reorder tableView
        let index = CoreDataHelper.getRecordsCount()
        
        switch identifier {
            case "save" where theme != nil:
                theme?.name = themeTitle
                theme?.content = text
                theme?.image = image
                theme?.thumbnail = thumbnail
                CoreDataHelper.saveTheme()
                
                //Storekit (app review)
                StoreKitHelper.displayStoreKit()
                
            case "save" where theme == nil:
                let newTheme = CoreDataHelper.newTheme()
                newTheme.name = themeTitle
                newTheme.content = text
                newTheme.image = image
                newTheme.thumbnail = thumbnail
                newTheme.orderIndex = index
                CoreDataHelper.saveTheme()
            default:
                print("unexpected segue identifier")
            }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
         let isPresentingInAddThemeMode = presentingViewController is UINavigationController
         if isPresentingInAddThemeMode {
             dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "cancel", sender: self)
         } else if let owningNavigationController = navigationController {
             owningNavigationController.popViewController(animated: false)
         } else {
             fatalError("func cancel")
         }
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
