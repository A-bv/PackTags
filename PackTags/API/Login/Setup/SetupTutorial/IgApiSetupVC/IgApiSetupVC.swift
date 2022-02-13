//
//  AnalyticsSetupVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class IgApiSetupVC: UIViewController {
    
    deinit {
        print("deinit igApiSetupVC")
    }
    
    let clr = UITextView.appearance().tintColor.withAlphaComponent(0.6)
    let clr2  = UIColor.white
    let actions =  [#selector(loginFunc(_:)),
                    #selector(createPageFunc(_:)),
                    #selector(convertIGFunc(_:))]
    
    let labels = ["Login with FB",
                  "Create a FB Page",
                  "Convert your IG"]
    
    var buttons: [UIButton] = []
    
    var numberOfButtons = 3
    
    let cstH = UIScreen.main.bounds.height >= 600.0 ? CGFloat(80.0) : CGFloat(65.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBlur()
        self.modalUI(arrowButton: false)
        self.buildUI()
        
    }
    

}






