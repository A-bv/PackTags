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
    
    private enum Strings {
        static let switchAccount = "Switch account"
        static let createAPage = "Create a page"
        static let login = "login"
        static let accountLinkingTitle = "Account Linking"
    }
    
    let actions =  [#selector(loginFunc(_:)),
                    #selector(createPageFunc(_:)),
                    #selector(convertIGFunc(_:))]
    
    static var businessAccAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: instagramIconAttachment))
        attributedString.append(NSAttributedString(string: "   \(Strings.switchAccount)"))
        return attributedString
    }
    
    static var facebookPageAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: facebookIconAttachment))
        attributedString.append(NSAttributedString(string: "  \(Strings.createAPage)"))
        return attributedString
    }
    
    static var loginAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: facebookIconAttachment))
        attributedString.append(NSAttributedString(string: "  \(Strings.login)"))
        return attributedString
    }
    
    var labels = [
        loginAttributedString,
        facebookPageAttributedString,
        businessAccAttributedString]
    
    var buttons: [UIButton] = []
    
    let cstH = UIScreen.main.bounds.height >= 600.0 ? CGFloat(80.0) : CGFloat(65.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.buildUI()
    }
}
